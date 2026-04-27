import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../firebase/models/task.dart';
import '../../redux/app/app_state.dart';
import '../../redux/tasks/tasks_actions.dart';
import '../common/right_down_float_button.dart';
import '../edit_task/edit_task_view.dart';
import '../profile/profile_view.dart';
import 'tasks_row.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  bool _hideCompleted = true;
  String? _subscribedForUserId;
  Store<AppState>? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreProvider.of<AppState>(context, listen: false);
  }

  @override
  void dispose() {
    _store?.dispatch(unsubscribeTasks());
    super.dispose();
  }

  void _ensureSubscribed(BuildContext context, String userId) {
    if (_subscribedForUserId == userId) return;
    _subscribedForUserId = userId;
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(subscribeTasks(userId));
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                  'Would you want to delete this task?\n"${task.title}"',
                  textAlign: TextAlign.center),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
    if (shouldDelete == true && context.mounted) {
      StoreProvider.of<AppState>(context).dispatch(deleteTask(task));
    }
  }

  void _openEditor(BuildContext context, EditTaskMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditTaskView(mode: mode),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ProfileView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) {
        final user = appState.authState.user;
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _ensureSubscribed(context, user.id);
          });
        }

        final visible = _hideCompleted
            ? appState.tasksState.tasks.where((t) => !t.completed).toList()
            : appState.tasksState.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, size: 30),
                onPressed: () => _openProfile(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text('Hide Completed Tasks'),
                        const Spacer(),
                        Switch(
                          value: _hideCompleted,
                          onChanged: (v) =>
                              setState(() => _hideCompleted = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (_, i) {
                        final task = visible[i];
                        return GestureDetector(
                          onLongPress: () => _showContextMenu(context, task),
                          child: TasksRow(
                            task: task,
                            onTapCompleted: () =>
                                StoreProvider.of<AppState>(context)
                                    .dispatch(toggleTaskCompleted(task)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              RightDownFloatButton(
                onTap: () {
                  if (user != null) {
                    _openEditor(context, NewTaskMode(user.id));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openEditor(context, EditExistingTaskMode(task));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(context, task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
