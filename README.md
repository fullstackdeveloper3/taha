# FireTodo (Flutter port)

Android Flutter port of the original SwiftUI **FireTodo** sample. Keeps the same
architecture: Redux (via `flutter_redux` + `redux_thunk`) with feature slices
for `auth`, `signUp`, `tasks`, `editTask`, and Firebase (Anonymous Auth + Cloud
Firestore) as the backend.

## Structure

```
lib/
  main.dart                         # Firebase.initializeApp + StoreProvider
  firebase/
    models/app_user.dart
    models/task.dart
    paths.dart                      # collection/doc helpers
  redux/
    app/                            # AppState, appReducer, createAppStore
    middleware/logging_middleware.dart
    auth/                           # state, actions (thunks), reducer
    sign_up/
    tasks/
    edit_task/
  views/
    content_view.dart               # router: initial / signed-in / signed-out
    sign_up/sign_up_view.dart
    tasks/tasks_view.dart
    tasks/tasks_row.dart
    edit_task/edit_task_view.dart
    edit_task/color_select.dart
    profile/profile_view.dart
    common/loading_view.dart
    common/right_down_float_button.dart
```

## Firebase setup (required before first run)

1. Create a Firebase project.
2. Enable **Anonymous** sign-in in Authentication.
3. Enable **Cloud Firestore** (test mode is fine for dev).
4. Add an Android app with package name `com.example.fire_todo`
   (or change `applicationId` in `android/app/build.gradle.kts` and the
   `namespace` to match your own).
5. Download the generated `google-services.json` and place it at:

   ```
   android/app/google-services.json
   ```

   The Google Services Gradle plugin is already wired up.

## Run

```
flutter pub get
flutter run
```

The app targets Android; iOS was not generated.

## Data model

```
users/{uid}
  username: string
  createTime, updateTime: timestamp

users/{uid}/tasks/{taskId}
  title: string
  desc: string
  completed: bool
  color: "red" | "blue" | "green" | "gray"
  createTime, updateTime: timestamp
```

## Differences vs. the Swift original

- State management: ReSwift → `flutter_redux` + `redux_thunk` (same pattern).
- Combine's `Auth.stateDidChange` publisher → `FirebaseAuth.authStateChanges()`
  Stream subscription (stored in `AuthState.listener`, mirroring the Swift
  `AnyCancellable` stored in state — same Redux-purity caveats apply).
- `FireSnapshot<Snapshot<T>>` → hand-written `fromSnapshot` / `toCreateMap` /
  `toUpdateMap` on `AppUser` and `TaskModel`.
- Context menu (iOS long-press) → bottom sheet with Edit / Delete actions.
- Action sheets → `showModalBottomSheet` confirmations.
