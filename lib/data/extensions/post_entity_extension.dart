import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post_entity.dart';

extension PostEntityFirestore on PostEntity {
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static PostEntity fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostEntity(
      id: doc.id,
      uid: data['uid'] as String,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hasSentToServer: true,
    );
  }
}
