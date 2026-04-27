import '../auth/auth_state.dart';
import '../edit_task/edit_task_state.dart';
import '../sign_up/sign_up_state.dart';
import '../tasks/tasks_state.dart';

export '../auth/auth_state.dart';
export '../edit_task/edit_task_state.dart';
export '../sign_up/sign_up_state.dart';
export '../tasks/tasks_state.dart';

class AppState {
  final AuthState authState;
  final SignUpState signUpState;
  final TasksState tasksState;
  final EditTaskState editTaskState;

  const AppState({
    this.authState = const AuthState(),
    this.signUpState = const SignUpState(),
    this.tasksState = const TasksState(),
    this.editTaskState = const EditTaskState(),
  });

  AppState copyWith({
    AuthState? authState,
    SignUpState? signUpState,
    TasksState? tasksState,
    EditTaskState? editTaskState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      signUpState: signUpState ?? this.signUpState,
      tasksState: tasksState ?? this.tasksState,
      editTaskState: editTaskState ?? this.editTaskState,
    );
  }
}
