import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fe_testing_ta/app/app_constants.dart';
import 'package:fe_testing_ta/data/models/posts_page_model.dart';

import '../../core/errors/failures.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../extensions/post_entity_extension.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  @override
  Stream<Either<Failure, List<PostEntity>>> streamPosts({
    DocumentSnapshot? startAfter,
  }) {
    try {
      Query query = _firestoreService.firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.postsPerPage);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map((snapshot) {
        try {
          final posts = snapshot.docs
              .map((doc) => PostEntityFirestore.fromFirestore(doc))
              .toList();
          return Right<Failure, List<PostEntity>>(posts);
        } catch (e) {
          return Left<Failure, List<PostEntity>>(ServerFailure(e.toString()));
        }
      }).handleError((error) {
        return Left<Failure, List<PostEntity>>(ServerFailure(error.toString()));
      });
    } catch (e) {
      return Stream.value(Left<Failure, List<PostEntity>>(
        ServerFailure(e.toString()),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> addPost({
    required String uid,
    required String text,
    String? customId,
  }) async {
    try {
      final docRef = customId != null
          ? _firestoreService.firestore.collection('posts').doc(customId)
          : _firestoreService.firestore.collection('posts').doc();

      final post = PostEntity(
        id: docRef.id,
        uid: uid,
        text: text,
        createdAt: DateTime.now(),
      );

      await docRef.set(post.toFirestore(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPost(String id) async {
    try {
      final doc =
          await _firestoreService.firestore.collection('posts').doc(id).get();
      if (doc.exists) {
        final post = PostEntityFirestore.fromFirestore(doc);
        return Right(post);
      }
      return const Left(ServerFailure('Post not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostsPageModel>> getPostsPage({
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestoreService.firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.postsPerPage);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      final posts = snapshot.docs
          .map((doc) => PostEntityFirestore.fromFirestore(doc))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return Right(PostsPageModel(posts: posts, lastDocument: lastDoc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
