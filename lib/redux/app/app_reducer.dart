import '../auth/auth_reducer.dart';
import '../edit_task/edit_task_reducer.dart';
import '../sign_up/sign_up_reducer.dart';
import '../tasks/tasks_reducer.dart';
import 'app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  return state.copyWith(
    authState: authReducer(state.authState, action),
    signUpState: signUpReducer(state.signUpState, action),
    tasksState: tasksReducer(state.tasksState, action),
    editTaskState: editTaskReducer(state.editTaskState, action),
  );
}
