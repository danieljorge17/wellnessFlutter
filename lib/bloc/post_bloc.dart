import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _repository;
  StreamSubscription<List<Post>>? _postsSubscription;
  final Set<String> _submittedPostIds = {}; // Track submitted posts to prevent duplicates
  final _uuid = const Uuid();

  PostBloc({required PostRepository repository})
      : _repository = repository,
        super(const PostState()) {
    on<LoadPosts>(_onLoadPosts);
    on<PostsReceived>(_onPostsReceived);
    on<AddPost>(_onAddPost);
    on<PostSubmissionFailed>(_onPostSubmissionFailed);
    on<LoadMorePosts>(_onLoadMorePosts);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(state.copyWith(isLoading: true));

    await _postsSubscription?.cancel();
    _postsSubscription = _repository.streamPosts().listen(
      (posts) {
        add(PostsReceived(posts));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          error: error.toString(),
        ));
      },
    );
  }

  void _onPostsReceived(PostsReceived event, Emitter<PostState> emit) {
    // Merge server posts with optimistic posts
    final serverPosts = event.posts;
    final optimisticPosts = state.posts.where((p) => !p.hasSentToServer).toList();

    // Remove optimistic posts that now exist on server
    final serverPostIds = serverPosts.map((p) => p.id).toSet();
    final remainingOptimistic = optimisticPosts
        .where((p) => !serverPostIds.contains(p.id))
        .toList();

    // Combine and sort: optimistic posts first, then server posts
    final allPosts = [...remainingOptimistic, ...serverPosts];

    // Sort by createdAt descending
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(
      posts: allPosts,
      isLoading: false,
      hasMore: serverPosts.length >= PostRepository.postsPerPage,
    ));
  }

  Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
    // Generate a unique ID for idempotency
    final postId = _uuid.v4();

    // Check if we've already submitted this exact post (prevent duplicates)
    if (_submittedPostIds.contains(postId)) {
      return;
    }

    // Create optimistic post
    final optimisticPost = Post(
      id: postId,
      uid: event.uid,
      text: event.text,
      createdAt: DateTime.now(),
      hasSentToServer: false,
    );

    // Immediately add to UI
    final updatedPosts = [optimisticPost, ...state.posts];
    emit(state.copyWith(posts: updatedPosts));

    // Track that we've submitted this post
    _submittedPostIds.add(postId);

    // Attempt to save to Firestore
    try {
      await _repository.addPost(
        uid: event.uid,
        text: event.text,
        customId: postId,
      );
    } catch (e) {
      // If submission fails, mark the post as failed
      // In a production app, you might want to retry or show an error
      add(PostSubmissionFailed(postId));
    }
  }

  void _onPostSubmissionFailed(
    PostSubmissionFailed event,
    Emitter<PostState> emit,
  ) {
    // Remove the failed optimistic post
    final updatedPosts = state.posts.where((p) => p.id != event.postId).toList();
    emit(state.copyWith(
      posts: updatedPosts,
      error: 'Failed to submit post. Please check your connection.',
    ));

    // Remove from submitted IDs so it can be retried
    _submittedPostIds.remove(event.postId);
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<PostState> emit,
  ) async {
    if (!state.hasMore || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    // Get the last document for pagination
    final lastDoc = await _repository.getLastDocument(state.posts.length);

    if (lastDoc != null) {
      // This is a simplified version - in production, you'd handle pagination more robustly
      final morePostsStream = _repository.streamPosts(startAfter: lastDoc);

      await for (final morePosts in morePostsStream.take(1)) {
        final allPosts = [...state.posts, ...morePosts];
        emit(state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMore: morePosts.length >= PostRepository.postsPerPage,
        ));
        break;
      }
    } else {
      emit(state.copyWith(isLoading: false, hasMore: false));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
