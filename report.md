---
title: "FireTodo — Flutter Port of a SwiftUI/Firebase Todo Application"
subtitle: "Project Report"
author: "Engineering Team"
date: "2026-04-18"
---

# Executive Summary

FireTodo is a simple but architecturally complete task-management application. Its original implementation, released in 2019 by Suguru Kishimoto, served as a reference for combining three then-new technologies on Apple platforms: **SwiftUI** for declarative UI, **Combine** for reactive data, and **ReSwift** for Redux-style state management, with **Firebase Authentication** and **Cloud Firestore** as the backend.

This report describes a port of that application to **Flutter**, targeting Android. The port preserves the Redux architecture and the Firebase data model of the original, but replaces every Apple-specific component with its Dart/Flutter equivalent. The finished Android APK was successfully built and installed on a physical test device (Android 15).

The deliverable demonstrates that a SwiftUI+ReSwift codebase can be translated to Flutter with minimal semantic loss, and that Flutter's widget system is a natural fit for Redux-driven UIs through the `flutter_redux` package.

---

# 1. Background

## 1.1 The Original Application

The source project, `sgr-ksmt/FireTodo`, is an iOS app written in **Swift 5.1** for iOS 13 using **Xcode 11**. It implements a per-user task list with the following features:

- Anonymous user sign-up with a chosen username.
- Live-updating list of tasks ordered by most recently edited.
- Create, edit, delete, and toggle-complete operations.
- Four accent colors per task (red, blue, green, gray).
- A profile screen with a sign-out action.
- Full support for iOS light and dark mode.

The project was explicitly written as a teaching sample, showing how the three ingredients — SwiftUI, Combine, and ReSwift — combine to produce a small but non-trivial production-style app. It uses **FireSnapshot**, a Codable-based wrapper around Firestore, for all database access.

## 1.2 Motivation for a Flutter Port

The original project has several practical limitations:

1. It only runs on iOS, and building it requires macOS plus Xcode.
2. Its dependencies (Firebase 6.9, Xcode 11, Swift 5.1) are now six years out of date and no longer build cleanly on current toolchains without significant migration.
3. Many of the SwiftUI APIs used (`AnyView`-based routers, `ActionSheet`, `NavigationView`) have been superseded in later iOS releases.

A **Flutter** port addresses all three limitations in a single step: it can be built on any desktop OS, targets both Android and iOS from one codebase, and uses up-to-date Firebase SDKs. This report documents such a port, targeting Android as the initial platform.

---

# 2. Objectives

The port aimed to satisfy the following constraints:

| # | Objective | Status |
| --- | --- | --- |
| O1 | Preserve the Redux architecture of the original, including feature slices and thunk-based side effects. | Met |
| O2 | Preserve the Firestore data model so that the same Firebase backend can serve either implementation. | Met |
| O3 | Produce a debug-installable Android APK on a Linux build host. | Met |
| O4 | Keep the UI behaviour close to the original (sign-up, list, hide-completed toggle, context menu, edit form, sign-out confirmation). | Met |
| O5 | Use only actively-maintained, pub.dev-hosted dependencies. | Met |
| O6 | Pass `flutter analyze` with zero issues. | Met |

---

# 3. Technology Stack

## 3.1 Languages

| Language | Role | Version |
| --- | --- | --- |
| Dart | Application logic, UI, state management | 3.11.3 |
| Kotlin (Gradle DSL) | Android build scripts | 2.2.20 |
| Kotlin | Android host activity (auto-generated) | 2.2.20 |
| YAML | Dart package manifest | — |
| JSON | Firebase client configuration | — |

For comparison, the original Swift project uses **Swift 5.1** and **Ruby** (CocoaPods / Bundler) for its toolchain.

## 3.2 Frameworks and Packages

| Layer | Package | Version |
| --- | --- | --- |
| UI toolkit | Flutter SDK | 3.41.2 |
| State core | `redux` | 5.0.0 |
| State binding | `flutter_redux` | 0.10.0 |
| Async side effects | `redux_thunk` | 0.4.0 |
| Firebase bootstrap | `firebase_core` | 3.15.2 |
| Authentication | `firebase_auth` | 5.7.0 |
| Database | `cloud_firestore` | 5.6.12 |
| Linting | `flutter_lints` | 6.0.0 |

## 3.3 Android Build Configuration

| Setting | Value | Rationale |
| --- | --- | --- |
| `applicationId` | `com.example.fire_todo` | Must match the package name declared in `google-services.json`. |
| `minSdk` | 23 | Required by `firebase_auth` 5.x. |
| `targetSdk` / `compileSdk` | 34 | Current Google Play requirement. |
| Java source/target | 17 | Required by modern Android Gradle Plugin. |
| Kotlin JVM target | 17 | Matches Java level. |
| Android Gradle Plugin | 8.11.1 | Bundled with the Flutter Arch package. |
| Gradle distribution | 8.14.3 | Manually upgraded — the default template shipped Gradle 2.14.1 (2015) which cannot parse Java 17 version strings. |
| Google Services plugin | 4.4.2 | Consumes `google-services.json` at build time. |

---

# 4. Architecture

## 4.1 Redux Overview

The application uses the **Redux** unidirectional data-flow pattern. A single immutable tree, `AppState`, holds every piece of screen state. Widgets never mutate this tree directly; instead they **dispatch actions**, which pass through **middleware** before reaching **reducers** that return a new `AppState`.

```
user interaction
      │
      ▼
  View dispatches a ThunkAction
      │
      ▼
  thunkMiddleware runs async work
  (Firebase call, timer, etc.)
      │
      ▼
  thunk dispatches plain Action classes
      │
      ▼
  appReducer → slice reducers
      │
      ▼
  New AppState emitted
      │
      ▼
  StoreConnector rebuilds the widget
```

## 4.2 State Composition

`AppState` is composed of four feature slices, each with its own `State`, `Actions`, and `Reducer` files:

```
AppState
├── AuthState      — current user, auth listener, loading flag
├── SignUpState    — sign-up request flag and error
├── TasksState     — list of tasks, Firestore listener
└── EditTaskState  — create/edit request flag, saved flag
```

This structure is a one-to-one mapping of the original Swift project and makes it trivial to extend: adding a new feature (for example, user profile editing) is a matter of adding a new slice.

## 4.3 Side Effects

All asynchronous work — Firebase reads, writes, and listener management — lives in **thunks**. A thunk is a function that receives the `Store` and returns after (optionally) dispatching further actions. The app defines these thunks:

- `subscribeAuth`, `unsubscribeAuth`, `fetchUser`, `signOut`
- `signUp(name)`
- `subscribeTasks(userId)`, `unsubscribeTasks`, `deleteTask`, `toggleTaskCompleted`
- `saveTask(userId, task)`, `updateTask(task)`

Logging is implemented as a custom middleware (`LoggingMiddleware`) that prints `[dispatch]: ActionTypeName` for every action, giving a live audit log during development.

## 4.4 View Layer

Every screen is a widget that reads its state through a `StoreConnector`. The screen tree is:

- **ContentView** — routes between the initial splash, the sign-up view, and the tasks view based on `AuthState`.
- **SignUpView** — username entry (3–16 characters) and sign-up action.
- **TasksView** — the main list, with a hide-completed toggle, floating add button, and long-press context menu.
- **TasksRow** — one colored task card.
- **EditTaskView** — shared create / edit form for tasks, including the color picker.
- **ProfileView** — displays the username and a sign-out action.

Two small helper widgets — `LoadingView` and `RightDownFloatButton` — are reused across screens and correspond directly to the Swift project's `LoadingView` and `RightDownFloatButton`.

---

# 5. Firebase Integration

## 5.1 Services Used

| Service | Configuration |
| --- | --- |
| Authentication | Anonymous sign-in provider enabled. |
| Cloud Firestore | Native-mode database, currently running test-mode security rules. |

## 5.2 Project Identity

| Field | Value |
| --- | --- |
| Project ID | `taha-c97e3` |
| Project number | `191679195595` |
| Android app ID | `1:191679195595:android:48d1b0f5734fc9af4dee4e` |
| Package | `com.example.fire_todo` |
| Config file | `android/app/google-services.json` |

The config file is consumed at build time by the Google Services Gradle plugin, which generates Android resources containing the Firebase project metadata. At runtime `Firebase.initializeApp()` picks these up automatically — no Flutter-side `firebase_options.dart` is required when the build targets only Android.

## 5.3 Data Model

```
users/{userId}
  username:   string
  createTime: timestamp
  updateTime: timestamp

users/{userId}/tasks/{taskId}
  title:      string
  desc:       string
  completed:  boolean
  color:      "red" | "blue" | "green" | "gray"
  createTime: timestamp
  updateTime: timestamp
```

The task list uses a live `snapshots()` listener with `orderBy('updateTime', descending: true)` and `limit(30)`. This gives instant UI updates across devices without a refresh action.

## 5.4 Security Considerations

The database currently uses the default test-mode rules that allow any request until the test expiry. Before any real-world deployment, the rules should be replaced with a per-user scope:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

# 6. Build and Deployment

## 6.1 Build Host

| Component | Version |
| --- | --- |
| OS | Arch Linux (kernel 6.18) |
| Flutter | 3.41.2 |
| Dart | 3.11.3 |
| Android SDK | 36.1.0 |
| Java | OpenJDK 17.0.18 |
| Gradle | 8.14.3 (via wrapper) |

## 6.2 Commands

```
flutter pub get
flutter analyze
flutter build apk --debug
adb -s <device-id> install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 6.3 Outcome

- Static analysis: **No issues found.**
- First debug build time: **~10 minutes** (cold Gradle and Firebase SDK compilation).
- Incremental build time: **~30 seconds**.
- Debug APK size: **~150 MB**.
- Installation target: **ALI NX1, Android 15 (API 35)**.
- Install result: **Success.**

A release build with resource shrinking and R8 would reduce the APK to an estimated 15–20 MB; release signing and Play Store metadata were not configured for this deliverable.

---

# 7. Swift → Dart Translation Notes

| Swift concept | Dart / Flutter equivalent |
| --- | --- |
| `ReSwift.Store<AppState>` | `redux.Store<AppState>` |
| `StoreSubscriber` | `StoreConnector<AppState, VM>` from `flutter_redux` |
| `Thunk<AppState>` (ReSwiftThunk) | `ThunkAction<AppState>` (`redux_thunk`) |
| `@EnvironmentObject` | `StoreProvider.of<AppState>(context)` |
| `Combine.Publisher` + `AnyCancellable` | `Stream` + `StreamSubscription` |
| `FireSnapshot.Snapshot<T>` | Hand-written `fromSnapshot` / `toCreateMap` methods |
| `Auth.auth().combine.stateDidChange()` | `FirebaseAuth.instance.authStateChanges()` |
| SwiftUI `View` | Flutter `StatelessWidget` / `StatefulWidget` |
| iOS long-press context menu | `showModalBottomSheet` with Edit / Delete items |
| `ActionSheet` | Confirmation bottom sheet |
| SwiftUI `NavigationView` | `Navigator.push(MaterialPageRoute(fullscreenDialog: true, …))` |
| SF Symbols (`Image(systemName:)`) | Material `Icon(Icons.…)` |
| SwiftUI `Toggle` | Material `Switch` |

The mapping is almost mechanical; the only part that required a genuine design decision is the context menu, which has no direct Material equivalent. Using a long-press bottom sheet preserves the original's discoverability without introducing iOS-flavoured visuals on Android.

---

# 8. Known Limitations

1. **Security rules are permissive.** The Firestore database runs on default test-mode rules and must be hardened before any real use.
2. **Stream subscriptions stored in Redux state.** `AuthState.listener` and `TasksState.listener` hold `StreamSubscription` objects. This mirrors the original Swift implementation, which stores `AnyCancellable` and `ListenerRegistration` in state, but it is considered a Redux anti-pattern because the state tree is no longer serializable. A cleaner design would lift listeners out of state into a dedicated service.
3. **Error states are not surfaced.** Sign-up and edit-task errors are captured in state and printed to the console, but no user-facing error UI is rendered. This matches the original.
4. **No automated tests.** The default Flutter widget test was removed and not replaced. Adding reducer unit tests would be the highest-leverage addition.
5. **Android-only build.** `flutter create` was invoked with `--platforms=android`. iOS, macOS, and web can be added later with a single command, but are out of scope for this deliverable.
6. **Debug build only.** Release signing, App Bundle packaging, and ProGuard/R8 configuration have not been set up.

---

# 9. Conclusion

The port demonstrates that a moderately complex SwiftUI + ReSwift + Firebase codebase can be translated to Flutter with high architectural fidelity. Every feature slice in the Swift source maps to a structurally identical slice in Dart. The Flutter equivalents of SwiftUI's declarative UI, Combine's reactive streams, and ReSwift's typed reducers are all first-class and well-supported on pub.dev.

Practical gains from the port include:

- A single Android-buildable codebase runnable from a Linux workstation, with no Apple-specific tooling.
- Modern, actively-maintained Firebase SDKs.
- A static-analysis-clean baseline that is ready for further feature work (profile editing, test suite, tightened security rules, release packaging).

Recommended next steps, in priority order: apply restrictive Firestore rules, add reducer unit tests, render user-facing error states, and prepare a release build with proper signing.

---

# Appendix A — Repository Layout

```
fire_todo_flutter/
├── pubspec.yaml                                  Dart package manifest
├── pubspec.lock                                  Pinned dependency graph
├── analysis_options.yaml                         Lint configuration
├── README.md                                     Quick-start guide
├── PROJECT_OVERVIEW.md                           Exhaustive reference document
├── report.md                                     Source of this report
├── android/
│   ├── build.gradle.kts                          Root Android build
│   ├── settings.gradle.kts                       Plugin declarations
│   ├── gradle.properties                         JVM tuning
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties             Gradle 8.14.3
│   └── app/
│       ├── build.gradle.kts                      App module build (minSdk 23)
│       ├── google-services.json                  Firebase config
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── kotlin/com/example/fire_todo/MainActivity.kt
│           └── res/
├── lib/
│   ├── main.dart                                 Entry point
│   ├── firebase/
│   │   ├── models/app_user.dart
│   │   ├── models/task.dart
│   │   └── paths.dart
│   ├── redux/
│   │   ├── app/             app_state.dart, app_reducer.dart, create_store.dart
│   │   ├── middleware/      logging_middleware.dart
│   │   ├── auth/            auth_state.dart, auth_actions.dart, auth_reducer.dart
│   │   ├── sign_up/         sign_up_state.dart, sign_up_actions.dart, sign_up_reducer.dart
│   │   ├── tasks/           tasks_state.dart, tasks_actions.dart, tasks_reducer.dart
│   │   └── edit_task/       edit_task_state.dart, edit_task_actions.dart, edit_task_reducer.dart
│   └── views/
│       ├── content_view.dart
│       ├── common/          loading_view.dart, right_down_float_button.dart
│       ├── sign_up/         sign_up_view.dart
│       ├── tasks/           tasks_view.dart, tasks_row.dart
│       ├── edit_task/       edit_task_view.dart, color_select.dart
│       └── profile/         profile_view.dart
└── build/                                        Gradle output (gitignored)
    └── app/outputs/flutter-apk/app-debug.apk
```

# Appendix B — Build Artifacts

| Artifact | Location |
| --- | --- |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| APK checksum | `build/app/outputs/flutter-apk/app-debug.apk.sha1` |
| Gradle cache | `~/.gradle/caches/` |
| Pub cache | `~/.pub-cache/` |
