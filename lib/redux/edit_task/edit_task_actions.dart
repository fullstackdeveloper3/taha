import 'package:redux_thunk/redux_thunk.dart';

import '../../firebase/models/task.dart';
import '../../firebase/paths.dart';
import '../app/app_state.dart';

class StartEditRequestAction {
  const StartEditRequestAction();
}

class EndEditRequestAction {
  const EndEditRequestAction();
}

class CloseEditViewAction {
  const CloseEditViewAction();
}

class ResetEditAction {
  const ResetEditAction();
}

ThunkAction<AppState> saveTask(String userId, TaskModel task) {
  return (store) async {
    store.dispatch(const StartEditRequestAction());
    try {
      await FirestorePaths.tasks(userId).add(task.toCreateMap());
      store.dispatch(const EndEditRequestAction());
      store.dispatch(const CloseEditViewAction());
    } catch (e) {
      // ignore: avoid_print
      print('saveTask error: $e');
      store.dispatch(const EndEditRequestAction());
    }
  };
}

ThunkAction<AppState> updateTask(TaskModel task) {
  return (store) async {
    store.dispatch(const StartEditRequestAction());
    try {
      await task.ref?.update(task.toUpdateMap());
      store.dispatch(const EndEditRequestAction());
      store.dispatch(const CloseEditViewAction());
    } catch (e) {
      // ignore: avoid_print
      print('updateTask error: $e');
      store.dispatch(const EndEditRequestAction());
    }
  };
}
