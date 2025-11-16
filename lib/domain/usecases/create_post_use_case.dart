import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  CreatePostUseCase(this.repository);

  final PostRepository repository;

  Future<Either<Failure, void>> call({
    required String uid,
    required String text,
    String? customId,
  }) =>
      repository.addPost(
        uid: uid,
        text: text,
        customId: customId,
      );
}
