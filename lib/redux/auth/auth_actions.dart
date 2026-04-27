import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux_thunk/redux_thunk.dart';

import '../../firebase/models/app_user.dart';
import '../../firebase/paths.dart';
import '../app/app_state.dart';

class FinishInitialLoadAction {
  const FinishInitialLoadAction();
}

class UpdateAuthListenerAction {
  final StreamSubscription<Object?>? listener;
  const UpdateAuthListenerAction(this.listener);
}

class UpdateUserAction {
  final AppUser? user;
  const UpdateUserAction(this.user);
}

ThunkAction<AppState> subscribeAuth() {
  return (store) {
    finishInitialLoad() {
      if (store.state.authState.loadingState == AuthLoadingState.initial) {
        store.dispatch(const FinishInitialLoadAction());
      }
    }

    final subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        store.dispatch(fetchUser(user.uid, onComplete: finishInitialLoad));
      } else {
        store.dispatch(const UpdateUserAction(null));
        finishInitialLoad();
      }
    });

    store.dispatch(UpdateAuthListenerAction(subscription));
  };
}

ThunkAction<AppState> unsubscribeAuth() {
  return (store) {
    store.state.authState.listener?.cancel();
    store.dispatch(const UpdateAuthListenerAction(null));
  };
}

ThunkAction<AppState> fetchUser(String uid, {void Function()? onComplete}) {
  return (store) async {
    try {
      final doc = await FirestorePaths.user(uid).get();
      if (doc.exists) {
        store.dispatch(UpdateUserAction(AppUser.fromSnapshot(doc)));
      } else {
        if (store.state.signUpState.requesting == false) {
          store.dispatch(signOut());
        }
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print('fetchUser error: $e');
      if (store.state.signUpState.requesting == false) {
        store.dispatch(signOut());
      }
    } finally {
      onComplete?.call();
    }
  };
}

ThunkAction<AppState> signOut() {
  return (store) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  };
}

