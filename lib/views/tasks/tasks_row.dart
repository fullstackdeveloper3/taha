import 'package:flutter/material.dart';

import '../../firebase/models/task.dart';

class TasksRow extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTapCompleted;

  const TasksRow({
    super.key,
    required this.task,
    required this.onTapCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.color.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  if (task.desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onTapCompleted,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                task.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
