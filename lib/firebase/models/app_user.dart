import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username;

  const AppUser({required this.id, required this.username});

  factory AppUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(id: doc.id, username: (data['username'] as String?) ?? '');
  }

  Map<String, dynamic> toCreateMap() => {
        'username': username,
        'createTime': FieldValue.serverTimestamp(),
        'updateTime': FieldValue.serverTimestamp(),
      };
}
