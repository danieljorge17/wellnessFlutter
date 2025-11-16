import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fe_testing_ta/data/models/posts_page_model.dart';

import '../../core/errors/failures.dart';
import '../repositories/post_repository.dart';

class GetPostsPageUseCase {
  final PostRepository repository;

  GetPostsPageUseCase(this.repository);

  Future<Either<Failure, PostsPageModel>> call({
    DocumentSnapshot? startAfter,
  }) =>
      repository.getPostsPage(startAfter: startAfter);
}
