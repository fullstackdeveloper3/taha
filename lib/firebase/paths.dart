import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePaths {
  static CollectionReference<Map<String, dynamic>> users() =>
      FirebaseFirestore.instance.collection('users');

  static DocumentReference<Map<String, dynamic>> user(String userId) =>
      users().doc(userId);

  static CollectionReference<Map<String, dynamic>> tasks(String userId) =>
      user(userId).collection('tasks');

  static DocumentReference<Map<String, dynamic>> task(
          String userId, String taskId) =>
      tasks(userId).doc(taskId);
}
