import 'package:redux_thunk/redux_thunk.dart';

import '../../firebase/models/task.dart';
import '../../firebase/paths.dart';
import '../app/app_state.dart';

class UpdateTasksAction {
  final List<TaskModel> tasks;
  const UpdateTasksAction(this.tasks);
}

class UpdateTasksListenerAction {
  final dynamic listener;
  const UpdateTasksListenerAction(this.listener);
}

ThunkAction<AppState> subscribeTasks(String userId) {
  return (store) {
    final query = FirestorePaths.tasks(userId)
        .orderBy('updateTime', descending: true)
        .limit(30);

    final sub = query.snapshots().listen((snap) {
      final tasks = snap.docs.map(TaskModel.fromSnapshot).toList();
      store.dispatch(UpdateTasksAction(tasks));
    }, onError: (Object error) {
      // ignore: avoid_print
      print('tasks listener error: $error');
      store.dispatch(const UpdateTasksAction([]));
    });

    store.dispatch(UpdateTasksListenerAction(sub));
  };
}

ThunkAction<AppState> unsubscribeTasks() {
  return (store) {
    final listener = store.state.tasksState.listener;
    listener?.cancel();
    store.dispatch(const UpdateTasksListenerAction(null));
  };
}

ThunkAction<AppState> deleteTask(TaskModel task) {
  return (store) async {
    await task.ref?.delete();
  };
}

ThunkAction<AppState> toggleTaskCompleted(TaskModel task) {
  return (store) async {
    final toggled = task.copyWith(completed: !task.completed);
    await task.ref?.update(toggled.toUpdateMap());
  };
}
