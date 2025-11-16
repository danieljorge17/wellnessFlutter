import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fe_testing_ta/app/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/create_post_use_case.dart';
import '../../../domain/usecases/get_posts_page_use_case.dart';
import '../../../domain/usecases/get_posts_stream_use_case.dart';
import '../../../domain/usecases/get_uuid_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required FirebaseAuth firebaseAuth,
    required GetPostsStreamUseCase getPostsStreamUseCase,
    required GetPostsPageUseCase getPostsPageUseCase,
    required CreatePostUseCase createPostUseCase,
    required GetUuidUseCase getUuidUseCase,
  })  : _firebaseAuth = firebaseAuth,
        _getPostsStreamUseCase = getPostsStreamUseCase,
        _getPostsPageUseCase = getPostsPageUseCase,
        _createPostUseCase = createPostUseCase,
        _getUuidUseCase = getUuidUseCase,
        super(const HomeState());

  final FirebaseAuth _firebaseAuth;
  final GetPostsStreamUseCase _getPostsStreamUseCase;
  final GetPostsPageUseCase _getPostsPageUseCase;
  final CreatePostUseCase _createPostUseCase;
  final GetUuidUseCase _getUuidUseCase;

  StreamSubscription<Either<Failure, List<PostEntity>>>? _postsSubscription;
  final Set<String> _submittedPostIds = {};
  DocumentSnapshot? _lastServerDocument;

  Future<void> loadPosts() async {
    emit(state.copyWith(isLoading: true));

    final initialResult = await _getPostsPageUseCase();

    await initialResult.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
      (postsPage) async {
        _lastServerDocument = postsPage.lastDocument;

        emit(state.copyWith(
          posts: postsPage.posts,
          isLoading: false,
          hasMore: postsPage.posts.length >= AppConstants.postsPerPage,
          lastDocument: _lastServerDocument,
        ));

        await _postsSubscription?.cancel();
        _postsSubscription = _getPostsStreamUseCase().listen(
          (either) {
            either.fold(
              (failure) {
                emit(state.copyWith(
                  isLoading: false,
                  error: failure.message,
                ));
              },
              (posts) {
                _onPostsReceived(posts);
              },
            );
          },
        );
      },
    );
  }

  void _onPostsReceived(List<PostEntity> serverPosts) {
    final optimisticPosts =
        state.posts.where((post) => !post.hasSentToServer).toList();

    final serverPostIds = serverPosts.map((post) => post.id).toSet();
    final remainingOptimistic = optimisticPosts
        .where((post) => !serverPostIds.contains(post.id))
        .toList();

    final allPosts = [...remainingOptimistic, ...serverPosts];

    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(
      posts: allPosts,
      isLoading: false,
      hasMore: serverPosts.length >= AppConstants.postsPerPage,
      lastDocument: _lastServerDocument,
    ));
  }

  Future<void> addPost({required String text}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(state.copyWith(
        error: 'Você precisa estar autenticado para criar um post.',
      ));
      return;
    }

    final postId = _getUuidUseCase();

    if (_submittedPostIds.contains(postId)) {
      return;
    }

    final optimisticPost = PostEntity(
      id: postId,
      uid: currentUser.uid,
      text: text,
      createdAt: DateTime.now(),
      hasSentToServer: false,
    );

    final updatedPosts = [optimisticPost, ...state.posts];
    emit(state.copyWith(posts: updatedPosts));

    _submittedPostIds.add(postId);

    final result = await _createPostUseCase(
      uid: currentUser.uid,
      text: text,
      customId: postId,
    );

    result.fold(
      (failure) {
        debugPrint('Error submitting post: ${failure.message}');
        _onPostSubmissionFailed(postId);
      },
      (_) {},
    );
  }

  void _onPostSubmissionFailed(String postId) {
    final updatedPosts =
        state.posts.where((post) => post.id != postId).toList();

    emit(state.copyWith(
      posts: updatedPosts,
      error: 'Failed to submit post. Please check your connection.',
    ));

    _submittedPostIds.remove(postId);
  }

  Future<void> loadMorePosts() async {
    if (!state.hasMore || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    final result = await _getPostsPageUseCase(startAfter: state.lastDocument);

    result.fold(
      (failure) {
        debugPrint('Error loading more posts: ${failure.message}');
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
      (postsPage) {
        final serverPosts =
            state.posts.where((post) => post.hasSentToServer).toList();

        final allPosts = [...serverPosts, ...postsPage.posts];

        allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _lastServerDocument = postsPage.lastDocument;

        emit(state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMore: postsPage.posts.length >= AppConstants.postsPerPage,
          lastDocument: _lastServerDocument,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
