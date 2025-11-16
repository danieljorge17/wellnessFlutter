import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fe_testing_ta/data/models/posts_page_model.dart';

import '../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Stream<Either<Failure, List<PostEntity>>> streamPosts({
    DocumentSnapshot? startAfter,
  });

  Future<Either<Failure, PostsPageModel>> getPostsPage({
    DocumentSnapshot? startAfter,
  });

  Future<Either<Failure, void>> addPost({
    required String uid,
    required String text,
    String? customId,
  });

  Future<Either<Failure, PostEntity>> getPost(String id);
}
