import 'dart:async';

import 'package:redux/redux.dart';

import 'tasks_actions.dart';
import 'tasks_state.dart';

final tasksReducer = combineReducers<TasksState>([
  TypedReducer<TasksState, UpdateTasksAction>(_updateTasks).call,
  TypedReducer<TasksState, UpdateTasksListenerAction>(_updateListener).call,
]);

TasksState _updateTasks(TasksState state, UpdateTasksAction action) =>
    state.copyWith(tasks: action.tasks);

TasksState _updateListener(TasksState state, UpdateTasksListenerAction action) {
  final listener = action.listener as StreamSubscription<Object?>?;
  return state.copyWith(
    listener: listener,
    clearListener: listener == null,
  );
}
