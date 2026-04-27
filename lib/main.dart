import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'redux/app/app_state.dart';
import 'redux/app/create_store.dart';
import 'views/content_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FireTodoApp(store: createAppStore()));
}

class FireTodoApp extends StatelessWidget {
  final Store<AppState> store;
  const FireTodoApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'FireTodo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.orange,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.orange,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const ContentView(),
      ),
    );
  }
}
