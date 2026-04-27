---
title: "FireTodo"
subtitle: "Porting a SwiftUI / Firebase / Redux app to Flutter"
author: "Engineering Team"
date: "2026-04-18"
---

# Overview

## What is FireTodo?

- Simple per-user todo application
- Originally released in 2019 as a SwiftUI + Firebase + Redux sample
- Features: anonymous sign-up, live task list, edit / toggle / delete, four color accents, profile + sign out
- This project: **port it to Flutter, targeting Android**

## Why port it?

- Original only runs on iOS, needs macOS + Xcode to build
- Dependencies six years out of date (Firebase 6.9, Xcode 11, Swift 5.1)
- Flutter gives: one codebase, any desktop build host, modern SDKs
- Good test case for Redux architecture portability

## Goals

- Preserve the Redux architecture and feature slices
- Preserve the Firestore data model (same backend serves both apps)
- Produce a debug-installable Android APK from Linux
- Pass `flutter analyze` with zero issues
- Keep UI behaviour close to the original

# Technology Stack

## Languages

- **Dart 3.11** — all application code
- **Kotlin 2.2** — Android host + Gradle scripts
- **YAML / JSON** — config (`pubspec.yaml`, `google-services.json`)
- Original used **Swift 5.1** + **Ruby** (CocoaPods)

## Key packages

| Layer | Package | Version |
|---|---|---|
| UI toolkit | Flutter SDK | 3.41.2 |
| Redux core | `redux` | 5.0.0 |
| Redux binding | `flutter_redux` | 0.10.0 |
| Async thunks | `redux_thunk` | 0.4.0 |
| Firebase bootstrap | `firebase_core` | 3.15.2 |
| Authentication | `firebase_auth` | 5.7.0 |
| Database | `cloud_firestore` | 5.6.12 |

## Android build

- `applicationId` = `com.example.fire_todo`
- `minSdk` = 23 (required by `firebase_auth` 5.x)
- `targetSdk` / `compileSdk` = 34
- Java + Kotlin JVM target = 17
- Gradle 8.14.3 (upgraded from 2.14.1 template default)
- Google Services Gradle plugin 4.4.2

# Architecture

## Redux, in one picture

```
User → View dispatches ThunkAction
        │
        ▼
   thunkMiddleware runs async work
        │
        ▼
   Plain Actions → appReducer
        │
        ▼
   New AppState → StoreConnector rebuilds View
```

- Single immutable tree
- Widgets read state, never mutate it
- Async isolated in thunks

## Four feature slices

```
AppState
├── AuthState      user, auth listener, loading flag
├── SignUpState    request flag, error
├── TasksState     tasks list, Firestore listener
└── EditTaskState  request flag, saved flag
```

- One-to-one mapping with the Swift original
- Each slice: `State`, `Actions`, `Reducer` files
- Adding a feature = adding a slice

## Side effects (thunks)

- **Auth** — `subscribeAuth`, `unsubscribeAuth`, `fetchUser`, `signOut`
- **SignUp** — `signUp(name)`
- **Tasks** — `subscribeTasks(uid)`, `unsubscribeTasks`, `deleteTask`, `toggleTaskCompleted`
- **EditTask** — `saveTask(uid, task)`, `updateTask(task)`
- Custom `LoggingMiddleware` prints every action for audit

## View tree

- **ContentView** — routes: splash / sign-up / tasks
- **SignUpView** — username entry (3–16 chars)
- **TasksView** — list, hide-completed toggle, FAB, long-press menu
- **TasksRow** — one colored card
- **EditTaskView** — shared create / edit form + color picker
- **ProfileView** — username + sign out
- Helpers: `LoadingView`, `RightDownFloatButton`, `ColorSelectView`

# Firebase

## Project configuration

- **Project ID:** `taha-c97e3`
- **Package:** `com.example.fire_todo`
- **Config file:** `android/app/google-services.json`
- **Authentication:** Anonymous sign-in enabled
- **Database:** Cloud Firestore (native mode, test-mode rules)

`Firebase.initializeApp()` auto-reads the Android resources generated from `google-services.json` — no Dart-side options file needed.

## Data model

```
users/{userId}
  username, createTime, updateTime

users/{userId}/tasks/{taskId}
  title, desc, completed,
  color: red | blue | green | gray,
  createTime, updateTime
```

- Task listener: `orderBy('updateTime' desc).limit(30)`
- Live updates across devices via `snapshots()` stream

## Security — known gap

- Currently **test-mode rules** (open to anyone)
- Must be tightened before any real use:

```
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
  match /tasks/{t} {
    allow read, write: if request.auth.uid == uid;
  }
}
```

# Build & Deployment

## Build host

- Arch Linux, kernel 6.18
- Flutter 3.41.2 / Dart 3.11.3
- Android SDK 36.1.0
- OpenJDK 17.0.18
- Gradle 8.14.3

## Build commands

```
flutter pub get
flutter analyze                       # No issues found
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Results

- Static analysis: **zero issues**
- First build: **~10 minutes** (cold Gradle + Firebase SDK)
- Incremental build: **~30 seconds**
- Debug APK: **~150 MB**
- Installed on: **ALI NX1, Android 15 (API 35) — success**

# Swift → Dart translation

## Concept mapping

| Swift | Dart / Flutter |
|---|---|
| `ReSwift.Store<AppState>` | `redux.Store<AppState>` |
| `StoreSubscriber` | `StoreConnector` |
| `Thunk<AppState>` | `ThunkAction<AppState>` |
| `@EnvironmentObject` | `StoreProvider.of(context)` |
| Combine + `AnyCancellable` | `Stream` + `StreamSubscription` |
| `FireSnapshot.Snapshot<T>` | Hand-written `fromSnapshot` / `toMap` |

## Concept mapping (continued)

| Swift | Dart / Flutter |
|---|---|
| SwiftUI `View` | `StatelessWidget` / `StatefulWidget` |
| iOS long-press menu | `showModalBottomSheet` |
| `ActionSheet` | Bottom sheet confirmation |
| `NavigationView` | `Navigator.push(...)` |
| SF Symbols | Material `Icon(Icons.…)` |
| SwiftUI `Toggle` | Material `Switch` |

Mapping is almost mechanical — only context-menu UX required a design decision.

# Limitations

## What's missing (and why)

- **Open Firestore rules** — still test-mode, must be restricted
- **Listeners stored in Redux state** — mirrors the Swift original, but breaks state serializability
- **No error UI** — errors captured in state but only `print`ed
- **No tests** — reducer unit tests are highest-leverage next step
- **Android only** — iOS can be added with one `flutter create` command
- **Debug build only** — no release signing, R8, or App Bundle

# Conclusion

## Takeaways

- SwiftUI + ReSwift ports to Flutter with **high architectural fidelity**
- Every Swift slice has a structurally identical Dart slice
- `flutter_redux` + `redux_thunk` = a first-class Redux experience on Flutter
- Port gains: modern SDKs, any-OS build host, future multi-platform

## Next steps (priority order)

1. Apply restrictive Firestore security rules
2. Add reducer unit tests
3. Render user-facing error states
4. Prepare signed release build + App Bundle
5. Generate iOS + web targets

## Questions?

Repository:

- Flutter port: `/home/codeilium/tahah/fire_todo_flutter/`
- Swift original: `/home/codeilium/tahah/FireTodo/`
- Project reference doc: `PROJECT_OVERVIEW.md`
- Report: `FireTodo_Report.odt`
