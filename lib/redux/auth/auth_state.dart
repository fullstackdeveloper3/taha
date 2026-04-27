import 'dart:async';

import '../../firebase/models/app_user.dart';

enum AuthLoadingState { initial, loaded }

class AuthState {
  final AuthLoadingState loadingState;
  final AppUser? user;
  final StreamSubscription<Object?>? listener;

  const AuthState({
    this.loadingState = AuthLoadingState.initial,
    this.user,
    this.listener,
  });

  AuthState copyWith({
    AuthLoadingState? loadingState,
    AppUser? user,
    bool clearUser = false,
    StreamSubscription<Object?>? listener,
    bool clearListener = false,
  }) {
    return AuthState(
      loadingState: loadingState ?? this.loadingState,
      user: clearUser ? null : (user ?? this.user),
      listener: clearListener ? null : (listener ?? this.listener),
    );
  }
}
