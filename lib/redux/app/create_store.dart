import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import '../middleware/logging_middleware.dart';
import 'app_reducer.dart';
import 'app_state.dart';

Store<AppState> createAppStore() {
  return Store<AppState>(
    appReducer,
    initialState: const AppState(),
    middleware: [thunkMiddleware, LoggingMiddleware().call],
  );
}
