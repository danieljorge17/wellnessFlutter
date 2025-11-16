import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String uid;
  final String text;
  final DateTime createdAt;
  final bool hasSentToServer;

  const Post({
    required this.id,
    required this.uid,
    required this.text,
    required this.createdAt,
    this.hasSentToServer = true,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      uid: data['uid'] as String,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hasSentToServer: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Post copyWith({
    String? id,
    String? uid,
    String? text,
    DateTime? createdAt,
    bool? hasSentToServer,
  }) {
    return Post(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      hasSentToServer: hasSentToServer ?? this.hasSentToServer,
    );
  }

  @override
  List<Object?> get props => [id, uid, text, createdAt, hasSentToServer];
}
