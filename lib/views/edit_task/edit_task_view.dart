import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../firebase/models/task.dart';
import '../../redux/app/app_state.dart';
import '../../redux/edit_task/edit_task_actions.dart';
import '../common/loading_view.dart';
import 'color_select.dart';

sealed class EditTaskMode {
  const EditTaskMode();
}

class NewTaskMode extends EditTaskMode {
  final String userId;
  const NewTaskMode(this.userId);
}

class EditExistingTaskMode extends EditTaskMode {
  final TaskModel task;
  const EditExistingTaskMode(this.task);
}

class EditTaskView extends StatefulWidget {
  final EditTaskMode mode;
  const EditTaskView({super.key, required this.mode});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _title;
  late String _desc;
  late TaskColor _color;
  bool _dismissed = false;

  bool get _isEditing => widget.mode is EditExistingTaskMode;

  @override
  void initState() {
    super.initState();
    final source = switch (widget.mode) {
      NewTaskMode _ => const TaskModel(),
      EditExistingTaskMode(task: final t) => t,
    };
    _title = source.title;
    _desc = source.desc;
    _color = source.color;
    _titleController = TextEditingController(text: _title);
    _descController = TextEditingController(text: _desc);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _canSave => _title.isNotEmpty;

  void _save(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    switch (widget.mode) {
      case NewTaskMode(userId: final uid):
        final newTask = TaskModel(
          title: _title,
          desc: _desc,
          color: _color,
        );
        store.dispatch(saveTask(uid, newTask));
      case EditExistingTaskMode(task: final existing):
        final updated = existing.copyWith(
          title: _title,
          desc: _desc,
          color: _color,
        );
        store.dispatch(updateTask(updated));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EditTaskState>(
      converter: (store) => store.state.editTaskState,
      onWillChange: (prev, next) {
        if (next.saved && !_dismissed) {
          _dismissed = true;
          Navigator.of(context).pop();
          StoreProvider.of<AppState>(context).dispatch(const ResetEditAction());
        }
      },
      builder: (context, editState) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(_isEditing ? 'Edit Task' : 'Create Task'),
            actions: [
              TextButton(
                onPressed: _canSave ? () => _save(context) : null,
                child: Text(_isEditing ? 'Edit' : 'Save'),
              ),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Title'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          hintText: 'e.g. Buy iPhone11 Pro'),
                      onChanged: (value) => setState(() => _title = value),
                    ),
                    const SizedBox(height: 32),
                    const Text('Description'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(hintText: '[Optional]'),
                      onChanged: (value) => setState(() => _desc = value),
                    ),
                    const SizedBox(height: 32),
                    const Text('Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in TaskColor.values) ...[
                          ColorSelectView(
                            color: c.color,
                            selected: c == _color,
                            onTap: () => setState(() => _color = c),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              LoadingView(isLoading: editState.requesting),
            ],
          ),
        );
      },
    );
  }
}
