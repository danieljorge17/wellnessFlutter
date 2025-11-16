import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post_entity.dart';

class PostsPageModel {
  const PostsPageModel({
    required this.posts,
    required this.lastDocument,
  });

  final List<PostEntity> posts;
  final DocumentSnapshot? lastDocument;
}
