import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.uid,
    required this.text,
    required this.createdAt,
    this.hasSentToServer = true,
  });

  final String id;
  final String uid;
  final String text;
  final DateTime createdAt;
  final bool hasSentToServer;

  PostEntity copyWith({
    String? id,
    String? uid,
    String? text,
    DateTime? createdAt,
    bool? hasSentToServer,
  }) {
    return PostEntity(
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
