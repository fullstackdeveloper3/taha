import 'dart:async';

import '../../firebase/models/task.dart';

class TasksState {
  final List<TaskModel> tasks;
  final StreamSubscription<Object?>? listener;

  const TasksState({this.tasks = const [], this.listener});

  TasksState copyWith({
    List<TaskModel>? tasks,
    StreamSubscription<Object?>? listener,
    bool clearListener = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      listener: clearListener ? null : (listener ?? this.listener),
    );
  }
}
