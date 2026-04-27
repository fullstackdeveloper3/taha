import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskColor {
  red,
  blue,
  green,
  gray;

  static TaskColor fromRaw(String raw) => TaskColor.values.firstWhere(
        (c) => c.name == raw,
        orElse: () => TaskColor.red,
      );

  Color get color {
    switch (this) {
      case TaskColor.red:
        return Colors.red;
      case TaskColor.blue:
        return Colors.blue;
      case TaskColor.green:
        return Colors.green;
      case TaskColor.gray:
        return Colors.grey;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String desc;
  final bool completed;
  final TaskColor color;
  final DocumentReference<Map<String, dynamic>>? ref;

  const TaskModel({
    this.id = '',
    this.title = '',
    this.desc = '',
    this.completed = false,
    this.color = TaskColor.red,
    this.ref,
  });

  factory TaskModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TaskModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      desc: (data['desc'] as String?) ?? '',
      completed: (data['completed'] as bool?) ?? false,
      color: TaskColor.fromRaw((data['color'] as String?) ?? 'red'),
      ref: doc.reference,
    );
  }

  TaskModel copyWith({
    String? title,
    String? desc,
    bool? completed,
    TaskColor? color,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      completed: completed ?? this.completed,
      color: color ?? this.color,
      ref: ref,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'title': title,
        'desc': desc,
        'completed': completed,
        'color': color.name,
        'createTime': FieldValue.serverTimestamp(),
        'updateTime': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'title': title,
        'desc': desc,
        'completed': completed,
        'color': color.name,
        'updateTime': FieldValue.serverTimestamp(),
      };
}
