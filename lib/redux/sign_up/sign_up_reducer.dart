import 'package:redux/redux.dart';

import 'sign_up_actions.dart';
import 'sign_up_state.dart';

final signUpReducer = combineReducers<SignUpState>([
  TypedReducer<SignUpState, SignUpStartedAction>(_started).call,
  TypedReducer<SignUpState, SignUpFinishedAction>(_finished).call,
  TypedReducer<SignUpState, SignUpFailedAction>(_failed).call,
]);

SignUpState _started(SignUpState state, SignUpStartedAction action) =>
    state.copyWith(requesting: true, clearError: true);

SignUpState _finished(SignUpState state, SignUpFinishedAction action) =>
    state.copyWith(requesting: false, clearError: true);

SignUpState _failed(SignUpState state, SignUpFailedAction action) =>
    state.copyWith(requesting: false, error: action.error);
