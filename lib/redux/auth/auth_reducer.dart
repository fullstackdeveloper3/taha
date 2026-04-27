import 'package:redux/redux.dart';

import 'auth_actions.dart';
import 'auth_state.dart';

final authReducer = combineReducers<AuthState>([
  TypedReducer<AuthState, FinishInitialLoadAction>(_finishInitialLoad).call,
  TypedReducer<AuthState, UpdateAuthListenerAction>(_updateListener).call,
  TypedReducer<AuthState, UpdateUserAction>(_updateUser).call,
]);

AuthState _finishInitialLoad(AuthState state, FinishInitialLoadAction action) {
  return state.copyWith(loadingState: AuthLoadingState.loaded);
}

AuthState _updateListener(AuthState state, UpdateAuthListenerAction action) {
  return state.copyWith(
    listener: action.listener,
    clearListener: action.listener == null,
  );
}

AuthState _updateUser(AuthState state, UpdateUserAction action) {
  return state.copyWith(user: action.user, clearUser: action.user == null);
}
