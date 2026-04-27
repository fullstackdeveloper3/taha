import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../redux/app/app_state.dart';
import '../redux/auth/auth_actions.dart';
import 'sign_up/sign_up_view.dart';
import 'tasks/tasks_view.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  Store<AppState>? _store;
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreProvider.of<AppState>(context, listen: false);
    if (!_subscribed) {
      _subscribed = true;
      _store!.dispatch(subscribeAuth());
    }
  }

  @override
  void dispose() {
    _store?.dispatch(unsubscribeAuth());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.authState,
      builder: (context, authState) {
        if (authState.loadingState == AuthLoadingState.initial) {
          return const Scaffold(body: SizedBox.shrink());
        }
        if (authState.user != null) {
          return const TasksView();
        }
        return const SignUpView();
      },
    );
  }
}
