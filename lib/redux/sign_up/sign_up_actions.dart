import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux_thunk/redux_thunk.dart';

import '../../firebase/models/app_user.dart';
import '../../firebase/paths.dart';
import '../app/app_state.dart';
import '../auth/auth_actions.dart';

class SignUpStartedAction {
  const SignUpStartedAction();
}

class SignUpFinishedAction {
  const SignUpFinishedAction();
}

class SignUpFailedAction {
  final Object error;
  const SignUpFailedAction(this.error);
}

ThunkAction<AppState> signUp(String name) {
  return (store) async {
    if (store.state.signUpState.requesting) return;

    store.dispatch(const SignUpStartedAction());
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      final uid = credential.user?.uid;
      if (uid == null) {
        store.dispatch(SignUpFailedAction(
            StateError('Anonymous sign-in returned no user.')));
        return;
      }

      final newUser = AppUser(id: uid, username: name);
      await FirestorePaths.user(uid).set(newUser.toCreateMap());

      store.dispatch(fetchUser(uid, onComplete: () {
        store.dispatch(const SignUpFinishedAction());
      }));
    } on FirebaseException catch (e) {
      store.dispatch(SignUpFailedAction(e));
    }
  };
}
