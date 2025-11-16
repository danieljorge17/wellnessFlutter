import 'package:equatable/equatable.dart';
import '../models/post.dart';

class PostState extends Equatable {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const PostState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [posts, isLoading, hasMore, error];
}
