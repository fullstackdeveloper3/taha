import 'package:redux/redux.dart';

import 'edit_task_actions.dart';
import 'edit_task_state.dart';

final editTaskReducer = combineReducers<EditTaskState>([
  TypedReducer<EditTaskState, StartEditRequestAction>(_start).call,
  TypedReducer<EditTaskState, EndEditRequestAction>(_end).call,
  TypedReducer<EditTaskState, CloseEditViewAction>(_close).call,
  TypedReducer<EditTaskState, ResetEditAction>(_reset).call,
]);

EditTaskState _start(EditTaskState state, StartEditRequestAction action) =>
    state.copyWith(requesting: true);

EditTaskState _end(EditTaskState state, EndEditRequestAction action) =>
    state.copyWith(requesting: false);

EditTaskState _close(EditTaskState state, CloseEditViewAction action) =>
    state.copyWith(saved: true);

EditTaskState _reset(EditTaskState state, ResetEditAction action) =>
    const EditTaskState();
