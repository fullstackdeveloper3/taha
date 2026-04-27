# FireTodo — Full Project Overview

This document is a complete reference for the **FireTodo** project as it exists in this repository. It is intended to be handed to a second AI so it can generate a report or presentation without needing to read the source tree directly. Every architectural decision, file, dependency, and piece of configuration that matters is listed here.

---

## 1. At a Glance

| | |
| --- | --- |
| **App type** | Cross-platform (currently built for Android) simple Todo app |
| **Original** | SwiftUI/iOS sample by Suguru Kishimoto ([`sgr-ksmt/FireTodo`](https://github.com/sgr-ksmt/FireTodo)) |
| **This repo** | Two sibling projects: the original Swift iOS source (`FireTodo/`) and a Flutter port (`fire_todo_flutter/`) |
| **Architecture** | Redux with feature slices (Auth / SignUp / Tasks / EditTask) |
| **Backend** | Firebase — Anonymous Authentication + Cloud Firestore |
| **Build target (this port)** | Android only (iOS scaffolding not generated) |
| **Installed on** | ALI NX1, Android 15 (API 35), debug APK (~150 MB) |

---

## 2. Languages Used

| Language | Where | Purpose |
| --- | --- | --- |
| **Swift 5.1** | `FireTodo/**/*.swift` | Original iOS app (UI + business logic + Redux) |
| **Dart 3.11** | `fire_todo_flutter/lib/**/*.dart` | Flutter port — all UI and business logic |
| **Kotlin 2.2** | Implicit via Flutter plugins + Android Gradle DSL | Android host glue (auto-generated); Gradle scripts (`*.gradle.kts`) |
| **Gradle Kotlin DSL** | `fire_todo_flutter/android/**/*.gradle.kts` | Build configuration for Android |
| **YAML** | `pubspec.yaml`, `.github/workflows`, etc. | Dart package manifest and CI config |
| **JSON** | `android/app/google-services.json` | Firebase client config for Android |
| **Markdown** | `README.md`, this file | Docs |

---

## 3. Original Swift Project (`FireTodo/`)

Included for context; not modified in this work.

### 3.1 Stack

- **UI:** SwiftUI (iOS 13.0+)
- **State:** ReSwift 5.0 + ReSwiftThunk 1.2 (Redux with thunks for async side effects)
- **Async:** Combine (Apple's reactive framework)
- **Firebase SDK:** Firebase 6.9 (`Firebase/Core`, `Firebase/Auth`, `Firebase/Firestore`)
- **Firestore Codable bridge:** [`FireSnapshot`](https://github.com/sgr-ksmt/FireSnapshot) ~> 0.6
- **Build system:** Xcode 11, CocoaPods
- **Lint/format:** SwiftLint 0.35, SwiftFormat 0.40

### 3.2 Swift file inventory (33 files)

```
FireTodo/
  AppDelegate.swift              # UIKit bootstrap, Firebase.configure()
  SceneDelegate.swift            # Hosts SwiftUI in UIHostingController; injects AppStore
  ContentView.swift              # Auth-state router (initial / signed-in / signed-out)
  Info.plist                     # iOS app manifest

  Combine/
    Auth+Combine.swift           # Wraps FIRAuth.stateDidChange into a Combine Publisher

  Firebase/
    Model.swift                  # Namespaces: Model.User, Model.Task + FireSnapshot paths
    Task.swift                   # Model.Task struct + TaskColor enum (red/blue/green/gray)
    User.swift                   # Model.User struct (username)
    Snapshot+Identifiable.swift  # Adapts FireSnapshot's Snapshot<T> to SwiftUI ForEach

  Redux/
    App/
      AppState.swift             # Composed root state (authState + signUpState + tasksState + editTaskState)
      AppReducer.swift           # Root reducer that delegates to slice reducers
    Main/
      AppMain.swift              # Composition root — creates Store with middleware
      AppStore.swift             # ObservableObject wrapper around ReSwift Store for SwiftUI
    Auth/
      AuthState.swift            # { loadingState, user, listenerCancellable }
      AuthAction.swift           # subscribe/unsubscribe/fetchUser/signOut thunks
      AuthReducer.swift
    SignUp/
      SignUpState.swift          # { requesting, error }
      SignUpAction.swift         # signUp(name) thunk (anonymous auth + create user doc)
      SignUpReducer.swift
    Tasks/
      TasksState.swift           # { tasks[], tasksListener }
      TasksAction.swift          # subscribe(userID)/unsubscribe/delete/toggleCompleted thunks
      TasksReducer.swift
    EditTask/
      EditTaskState.swift        # { requesting, saved, error }
      EditTaskAction.swift       # saveTask/updateTask thunks
      EditTaskReducer.swift
    Middleware/
      Thunk/ThunkAction.swift    # typealias AppThunkAction = Thunk<AppState>
      Logging/LoggingMiddleware.swift  # Prints every dispatched action

  Views/
    Common/
      LoadingView.swift          # Full-screen loading overlay
      RightDownFloatButton.swift # Floating Action Button for adding tasks
      PresentationView.swift     # Identifiable sheet wrapper
      WidthFillPlaceHolderView.swift
    Tasks/
      TasksView.swift            # Main list + hide-completed toggle + context menu
      TasksRow.swift             # Rounded colored task card
    SignUp/
      SignUpView.swift           # Name entry (3-16 chars) + Sign Up button
    EditTask/
      EditTaskView.swift         # Create/Edit form with title/desc/color picker
      ColorSelectView.swift      # Round color swatch with selected highlight
    Profile/
      ProfileView.swift          # Username display + Sign Out
```

### 3.3 Setup (not executable on this Linux machine)

```sh
cd FireTodo
make                 # scripts/setup.sh — bundle install, pod install
open FireTodo.xcworkspace
```
Requires macOS + Xcode. `GoogleService-Info.plist` must be added to the Xcode target.

---

## 4. Flutter Port (`fire_todo_flutter/`) — the active project

### 4.1 Stack

| Layer | Package / version |
| --- | --- |
| SDK | Flutter **3.41.2** / Dart **3.11.3** (channel: Arch Linux AUR build) |
| State (Redux) | `redux` ^5.0.0, `flutter_redux` ^0.10.0, `redux_thunk` ^0.4.0 |
| Firebase core | `firebase_core` ^3.6.0 (installed 3.15.2) |
| Firebase Auth | `firebase_auth` ^5.3.1 (installed 5.7.0) |
| Firestore | `cloud_firestore` ^5.4.3 (installed 5.6.12) |
| Lint | `flutter_lints` ^6.0.0 |
| Icons | `cupertino_icons` ^1.0.8 |

Exact dependency tree is frozen in `pubspec.lock`.

### 4.2 Android build configuration

| Property | Value | Reason |
| --- | --- | --- |
| `namespace` | `com.example.fire_todo` | Matches Firebase Android app |
| `applicationId` | `com.example.fire_todo` | Must match `google-services.json` package_name |
| `minSdk` | **23** | Required by `firebase_auth` 5.x |
| `targetSdk` | `flutter.targetSdkVersion` (latest stable, 34) | Google Play requirement |
| `compileSdk` | `flutter.compileSdkVersion` (34) | AGP default |
| Java | 17 | `sourceCompatibility` / `targetCompatibility` |
| Kotlin JVM target | 17 | `kotlinOptions.jvmTarget` |
| Android Gradle Plugin | 8.11.1 | Declared in `settings.gradle.kts` |
| Kotlin plugin | 2.2.20 | Declared in `settings.gradle.kts` |
| Google Services plugin | 4.4.2 | Required by Firebase — declared + applied in `android/app/build.gradle.kts` |
| Gradle distribution | **8.14.3** | Had to manually upgrade — default template shipped Gradle 2.14.1 (2015) which is incompatible with Java 17 |

### 4.3 Files changed from vanilla `flutter create` output

| File | Change |
| --- | --- |
| `pubspec.yaml` | Added Firebase + Redux dependencies |
| `android/settings.gradle.kts` | Added `com.google.gms.google-services` plugin declaration |
| `android/app/build.gradle.kts` | Applied Google Services plugin; bumped `minSdk` to 23 |
| `android/gradle/wrapper/gradle-wrapper.properties` | Upgraded `distributionUrl` to `gradle-8.14.3-all.zip` |
| `android/app/google-services.json` | **User-provided** — Firebase config (see §5) |
| `lib/main.dart` | Replaced default counter app with `FireTodoApp` (StoreProvider + MaterialApp + ContentView) |
| `test/widget_test.dart` | Deleted (template test no longer applicable) |
| `lib/**` (new) | All application code (see §4.5) |

### 4.4 Directory tree (active project)

```
fire_todo_flutter/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml            # Lint rules (default flutter_lints)
├── README.md
├── PROJECT_OVERVIEW.md              # (this file)
├── android/
│   ├── build.gradle.kts             # Root Android build file
│   ├── settings.gradle.kts          # Plugin management (AGP, Kotlin, Google Services)
│   ├── gradle.properties            # JVM args (Xmx=8G, Metaspace=4G)
│   ├── local.properties             # Flutter SDK path (machine-specific)
│   ├── gradle/wrapper/
│   │   ├── gradle-wrapper.jar
│   │   └── gradle-wrapper.properties
│   └── app/
│       ├── build.gradle.kts         # Module build file
│       ├── google-services.json     # Firebase config (secret, committed locally)
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── kotlin/com/example/fire_todo/MainActivity.kt
│           └── res/                 # Icons + themes
├── lib/
│   ├── main.dart
│   ├── firebase/
│   │   ├── models/
│   │   │   ├── app_user.dart
│   │   │   └── task.dart
│   │   └── paths.dart
│   ├── redux/
│   │   ├── app/
│   │   │   ├── app_state.dart
│   │   │   ├── app_reducer.dart
│   │   │   └── create_store.dart
│   │   ├── middleware/
│   │   │   └── logging_middleware.dart
│   │   ├── auth/
│   │   │   ├── auth_state.dart
│   │   │   ├── auth_actions.dart
│   │   │   └── auth_reducer.dart
│   │   ├── sign_up/
│   │   │   ├── sign_up_state.dart
│   │   │   ├── sign_up_actions.dart
│   │   │   └── sign_up_reducer.dart
│   │   ├── tasks/
│   │   │   ├── tasks_state.dart
│   │   │   ├── tasks_actions.dart
│   │   │   └── tasks_reducer.dart
│   │   └── edit_task/
│   │       ├── edit_task_state.dart
│   │       ├── edit_task_actions.dart
│   │       └── edit_task_reducer.dart
│   └── views/
│       ├── content_view.dart        # Auth router (initial / signed-in / signed-out)
│       ├── common/
│       │   ├── loading_view.dart
│       │   └── right_down_float_button.dart
│       ├── sign_up/
│       │   └── sign_up_view.dart
│       ├── tasks/
│       │   ├── tasks_view.dart
│       │   └── tasks_row.dart
│       ├── edit_task/
│       │   ├── edit_task_view.dart
│       │   └── color_select.dart
│       └── profile/
│           └── profile_view.dart
├── test/                            # (empty after default test removed)
└── build/                           # Gradle + Flutter build artefacts (gitignored)
    └── app/outputs/flutter-apk/app-debug.apk   # ~150 MB debug build
```

### 4.5 File-by-file description (Flutter)

**Entry point**

- `lib/main.dart` — calls `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp()` (reads `google-services.json` via the native Android Firebase SDK), then wraps the app in `StoreProvider<AppState>` and `MaterialApp`. Theme uses Material 3 with orange seed color, light + dark themes tied to system.

**Firebase models & paths**

- `firebase/models/app_user.dart` — plain Dart class `AppUser {id, username}` with `fromSnapshot` and `toCreateMap` (adds server timestamps).
- `firebase/models/task.dart` — `TaskModel` (`id/title/desc/completed/color/ref`) and `TaskColor` enum (`red/blue/green/gray`) with `.color` getter mapping to Flutter `Colors.*`. Includes `fromSnapshot`, `copyWith`, `toCreateMap`, `toUpdateMap` (server timestamp only on update).
- `firebase/paths.dart` — helper functions `users()`, `user(uid)`, `tasks(uid)`, `task(uid, taskId)` returning typed Firestore references.

**Redux core**

- `redux/app/app_state.dart` — `AppState { authState, signUpState, tasksState, editTaskState }` + `copyWith`. Re-exports slice states via `export`.
- `redux/app/app_reducer.dart` — `appReducer(state, action)` that forwards to each slice reducer and rebuilds `AppState`.
- `redux/app/create_store.dart` — `createAppStore()` returns a `Store<AppState>` with middleware: `thunkMiddleware` + `LoggingMiddleware`.
- `redux/middleware/logging_middleware.dart` — Prints `[dispatch]: ActionTypeName` for every action.

**Auth slice** (`redux/auth/`)

- `auth_state.dart` — `AuthState { loadingState (initial|loaded), user: AppUser?, listener: StreamSubscription? }` + `copyWith`.
- `auth_actions.dart`:
  - Action classes: `FinishInitialLoadAction`, `UpdateAuthListenerAction`, `UpdateUserAction`.
  - Thunks:
    - `subscribeAuth()` — starts listening to `FirebaseAuth.authStateChanges()`. When a user appears, dispatches `fetchUser(uid)`; when it disappears, dispatches `UpdateUserAction(null)`.
    - `unsubscribeAuth()` — cancels the stored subscription.
    - `fetchUser(uid)` — reads `users/{uid}` doc; if missing and no sign-up in flight, auto-signs-out.
    - `signOut()` — calls `FirebaseAuth.signOut()`.
- `auth_reducer.dart` — typed reducers handling each action.

**SignUp slice**

- `sign_up_state.dart` — `{ requesting: bool, error: Object? }`.
- `sign_up_actions.dart`:
  - `SignUpStartedAction`, `SignUpFinishedAction`, `SignUpFailedAction(error)`.
  - `signUp(name)` thunk: calls `FirebaseAuth.signInAnonymously()`, then writes `users/{uid}` doc with `{ username, createTime, updateTime }`, then dispatches `fetchUser` and finally `SignUpFinishedAction`.

**Tasks slice**

- `tasks_state.dart` — `{ tasks: List<TaskModel>, listener: StreamSubscription? }`.
- `tasks_actions.dart`:
  - `UpdateTasksAction(tasks)`, `UpdateTasksListenerAction(sub)`.
  - `subscribeTasks(uid)` — opens a live snapshot listener on `users/{uid}/tasks` ordered by `updateTime desc`, limit 30.
  - `unsubscribeTasks()` — cancels listener.
  - `deleteTask(task)` — `task.ref?.delete()`.
  - `toggleTaskCompleted(task)` — flips `completed`, writes back via `task.ref?.update(...)` with new `updateTime`.

**EditTask slice**

- `edit_task_state.dart` — `{ requesting, saved, error }`.
- `edit_task_actions.dart`:
  - `StartEditRequestAction`, `EndEditRequestAction`, `CloseEditViewAction`, `ResetEditAction`.
  - `saveTask(uid, task)` — `add()` a new doc with timestamps; on success dispatch `CloseEditViewAction`.
  - `updateTask(task)` — `update()` the existing doc.

**Views**

- `views/content_view.dart` — on first dependency change subscribes to auth; on dispose unsubscribes. Branches on `AuthState.loadingState` → empty splash, `SignUpView`, or `TasksView`.
- `views/sign_up/sign_up_view.dart` — text field (3-16 char validation), `Sign Up` button dispatches the `signUp` thunk. Shows `LoadingView` while `requesting`.
- `views/tasks/tasks_view.dart` — AppBar with profile icon, toggle `Hide Completed Tasks`, `ListView.builder` of `TasksRow`, `RightDownFloatButton` opens `EditTaskView(NewTaskMode)`. Long-press on row opens a bottom sheet with Edit / Delete actions. Delete confirmation is a second bottom sheet with a red destructive button.
- `views/tasks/tasks_row.dart` — padded rounded card colored by `task.color`, title/desc column, check/uncheck circle on the right that dispatches `toggleTaskCompleted`.
- `views/edit_task/edit_task_view.dart` — Stateful form (title/desc/color), `sealed class EditTaskMode { NewTaskMode(uid), EditExistingTaskMode(task) }` pattern-matched with Dart 3 `switch`. Listens to `editTaskState.saved` via `StoreConnector`'s `onWillChange` to pop and dispatch `ResetEditAction`.
- `views/edit_task/color_select.dart` — 40px circular swatch with optional border ring when selected; `AnimatedContainer` for smooth state change.
- `views/profile/profile_view.dart` — large avatar icon + username, `Sign Out` button that opens a confirmation bottom sheet; on confirm dispatches `signOut()` and pops.
- `views/common/loading_view.dart` — `Positioned.fill` semi-transparent overlay with `CircularProgressIndicator`. Uses `withValues(alpha: …)` (the deprecation-safe replacement for `withOpacity`).
- `views/common/right_down_float_button.dart` — `Positioned` bottom-right `FloatingActionButton` with `+` icon.

### 4.6 State → UI binding

All screens use `StoreConnector<AppState, SliceOrWhole>` with a `converter` that narrows the store to exactly the slice needed — this mirrors the `@EnvironmentObject private var store: AppStore` pattern used in the Swift version.

```
                ┌────────────────────────────┐
    user tap →  │        View (widget)       │
                └──────────────┬─────────────┘
                               │ dispatch(ThunkAction)
                               ▼
          ┌────────────────────────────────────────┐
          │ thunkMiddleware                        │
          │   runs async work (Firebase calls)     │
          │   dispatches plain Action classes      │
          └──────────────┬─────────────────────────┘
                         │
                         ▼
          ┌────────────────────────────────────────┐
          │ appReducer → slice reducers            │
          │   returns a new AppState               │
          └──────────────┬─────────────────────────┘
                         │
                         ▼
          ┌────────────────────────────────────────┐
          │ Store<AppState>.onChange stream        │
          └──────────────┬─────────────────────────┘
                         │
                         ▼
          ┌────────────────────────────────────────┐
          │ StoreConnector rebuilds the View       │
          └────────────────────────────────────────┘
```

---

## 5. Firebase Configuration

### 5.1 Project

| Field | Value |
| --- | --- |
| Project ID | `taha-c97e3` |
| Project number | `191679195595` |
| Storage bucket | `taha-c97e3.firebasestorage.app` |
| API key (Android) | `AIzaSyAB7E_HpsMiW8x6NvRcLK6Kjdg_PEWyuf0` (non-secret per Google — intended to be bundled in client apps) |

### 5.2 Services enabled

| Service | Configuration |
| --- | --- |
| **Authentication** | Anonymous sign-in enabled. No other providers. |
| **Cloud Firestore** | Native mode, started in **test mode** (rules default to `allow read, write: if request.time < …;` for ~30 days). **Must be hardened before any production use.** |

### 5.3 Client registration

- Only an **Android** app is registered with the Firebase project.
- Package name: `com.example.fire_todo`
- SHA-1 fingerprints: none added (fine for anonymous auth; required if/when Google Sign-In or dynamic links are added).
- App ID (`mobilesdk_app_id`): `1:191679195595:android:48d1b0f5734fc9af4dee4e`.
- OAuth clients: none.

The configuration file is at `android/app/google-services.json`. The Google Services Gradle plugin (`com.google.gms.google-services` 4.4.2) consumes it at build time to generate Android resources containing the Firebase metadata, which `Firebase.initializeApp()` picks up automatically (no `DefaultFirebaseOptions.currentPlatform` needed).

### 5.4 Firestore data model

```
users/{uid}                                       # DocumentReference<Map>
  username:    string
  createTime:  timestamp (FieldValue.serverTimestamp)
  updateTime:  timestamp (FieldValue.serverTimestamp)

  tasks/{taskId}                                  # subcollection
    title:      string
    desc:       string
    completed:  bool
    color:      "red" | "blue" | "green" | "gray"
    createTime: timestamp
    updateTime: timestamp
```

Queries used:
- Auth sign-up writes `users/{uid}` once.
- Tasks listener subscribes to `users/{uid}/tasks`, `orderBy('updateTime', descending: true)`, `limit(30)`.
- Toggle complete / edit do a `DocumentReference.update()` with a new `updateTime`.
- Delete does `DocumentReference.delete()`.

### 5.5 Firestore security rules

Currently running on the default **test-mode** rules generated by the Firebase Console (world-readable and world-writable until the test expiry). This is noted in the original project's TODO list and remains a known limitation.

A minimal production-grade rule set would look like:

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

## 6. Build & Run

### 6.1 Toolchain (verified on this machine)

| Tool | Version |
| --- | --- |
| Flutter | 3.41.2 (Arch AUR channel) |
| Dart | 3.11.3 |
| Android SDK | 36.1.0 (installed) |
| Java | OpenJDK 17.0.18 |
| Gradle | 8.14.3 (wrapper) |
| Target device | ALI NX1 (API 35) |
| `adb` | Android Debug Bridge present in `PATH` |

### 6.2 Commands

```sh
cd fire_todo_flutter
flutter pub get                                 # fetch dart deps
flutter analyze                                 # static analysis (currently: No issues found)
flutter build apk --debug                       # outputs build/app/outputs/flutter-apk/app-debug.apk
adb -s <device-id> install -r <path-to-apk>     # or: flutter install -d <device-id>
flutter run -d <device-id>                      # build+install+attach (hot reload)
```

First-time debug build takes ~10 minutes due to cold Gradle + Firebase SDK compilation. Subsequent incremental builds are ~30 s.

### 6.3 APK details

- Path: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: ~150 MB (debug; release with shrinking would be ~15–20 MB)
- Package: `com.example.fire_todo`
- Signing: debug keystore (Flutter default)

---

## 7. User-facing Flow

```
App launch
   │
   ▼
Firebase.initializeApp (reads google-services.json)
   │
   ▼
subscribeAuth() dispatched
   │
   ▼
AuthState.loadingState == initial  →  blank splash
   │
   ├── FirebaseAuth says no user  ─────────────►  SignUpView
   │         └── user enters name 3-16 chars
   │                    │  Sign Up button
   │                    ▼
   │            signUp() thunk:
   │              1. signInAnonymously()
   │              2. write users/{uid}
   │              3. fetchUser() populates AuthState.user
   │              4. SignUpFinishedAction
   │
   └── FirebaseAuth has a user  ───────────────►  TasksView
              │
              ├─ subscribeTasks(uid) — live listener
              │     ordered by updateTime desc, limit 30
              │
              ├─ FloatingActionButton
              │     └── EditTaskView(NewTaskMode)
              │
              ├─ Long-press on a row
              │     └── Bottom sheet: [Edit] [Delete]
              │          Edit   → EditTaskView(EditExistingTaskMode)
              │          Delete → confirmation bottom sheet → deleteTask
              │
              ├─ Tap circle on row → toggleTaskCompleted
              │
              └─ AppBar profile icon
                    └── ProfileView
                         └── Sign Out → signOut() → back to SignUpView
```

---

## 8. Known Issues / Limitations

- **Security rules are open.** The Firestore database is in test mode. Before any real use, apply the rule set in §5.5.
- **Listeners stored in Redux state.** `AuthState.listener` and `TasksState.listener` hold `StreamSubscription` objects. This mirrors the Swift original, where `AnyCancellable` and `ListenerRegistration` are stored in state. It works, but it violates strict Redux purity (state should be serializable) and complicates testing. A cleaner design would extract these to a non-Redux service.
- **No error UI.** `signUpState.error` and `editTaskState.error` are populated but never surfaced to the user — failures are only printed to the console (same as the Swift original).
- **No tests.** The default Flutter widget test was removed; no replacement was written. Unit tests for the reducers would be the highest-leverage additions.
- **No iOS build for the Flutter port.** `flutter create` was called with `--platforms=android`. iOS/macOS/web can be added later with `flutter create --platforms=ios,web .`.
- **No CI.** The original Swift repo has `.github/` workflows; the Flutter port does not.
- **Debug build only.** Release signing, App Bundle (`.aab`), and Play Store metadata have not been configured.

---

## 9. Mapping Swift → Dart (for the presentation)

| Swift concept | Dart equivalent in this port |
| --- | --- |
| `ReSwift.Store<AppState>` | `redux.Store<AppState>` |
| `StoreSubscriber` / `ObservableObject` | `StoreConnector<AppState, VM>` (from `flutter_redux`) |
| `ReSwiftThunk.Thunk<AppState>` | `ThunkAction<AppState>` from `redux_thunk` |
| `@EnvironmentObject var store: AppStore` | `StoreProvider<AppState>` + `StoreProvider.of(context)` |
| `Combine.Publisher` + `AnyCancellable` | `Stream` + `StreamSubscription` |
| `FireSnapshot.Snapshot<T>` | Hand-written `fromSnapshot` / `toCreateMap` on models |
| `Auth.auth().combine.stateDidChange()` | `FirebaseAuth.instance.authStateChanges()` |
| SwiftUI `View` | Flutter `StatelessWidget` / `StatefulWidget` |
| iOS context menu (long-press) | `showModalBottomSheet` with Edit / Delete actions |
| `ActionSheet` | `showModalBottomSheet` confirmation |
| `@State` / `@ObservedObject` | `setState()` / `StoreConnector` |
| `NavigationView` | `Navigator.push(MaterialPageRoute(fullscreenDialog: true, …))` |
| `Image(systemName: "person.crop.circle.fill")` | `Icon(Icons.account_circle)` |
| iOS `Toggle` | Material `Switch` |

---

## 10. Useful absolute paths on this machine

| Item | Path |
| --- | --- |
| Swift original | `/home/codeilium/tahah/FireTodo/` |
| Flutter port | `/home/codeilium/tahah/fire_todo_flutter/` |
| Flutter entry point | `/home/codeilium/tahah/fire_todo_flutter/lib/main.dart` |
| Firebase config | `/home/codeilium/tahah/fire_todo_flutter/android/app/google-services.json` |
| Debug APK | `/home/codeilium/tahah/fire_todo_flutter/build/app/outputs/flutter-apk/app-debug.apk` |
| Gradle wrapper properties | `/home/codeilium/tahah/fire_todo_flutter/android/gradle/wrapper/gradle-wrapper.properties` |
| Android app Gradle file | `/home/codeilium/tahah/fire_todo_flutter/android/app/build.gradle.kts` |

---

*Document generated for use as input to a downstream report/presentation generator. Everything above reflects the repository state as built and installed on device `AWCXUT3A08029162` on 2026-04-18.*
