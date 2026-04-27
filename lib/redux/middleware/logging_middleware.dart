import 'package:redux/redux.dart';

import '../app/app_state.dart';

class LoggingMiddleware implements MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    // ignore: avoid_print
    print('[dispatch]: ${action.runtimeType}');
    next(action);
  }
}
