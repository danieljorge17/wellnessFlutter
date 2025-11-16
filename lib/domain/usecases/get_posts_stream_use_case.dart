import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsStreamUseCase {
  GetPostsStreamUseCase(this.repository);

  final PostRepository repository;

  Stream<Either<Failure, List<PostEntity>>> call({
    DocumentSnapshot? startAfter,
  }) =>
      repository.streamPosts(startAfter: startAfter);
}
