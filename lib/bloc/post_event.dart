import 'package:equatable/equatable.dart';
import '../models/post.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start listening to posts stream
class LoadPosts extends PostEvent {
  const LoadPosts();
}

/// Event when posts are received from Firestore
class PostsReceived extends PostEvent {
  final List<Post> posts;

  const PostsReceived(this.posts);

  @override
  List<Object?> get props => [posts];
}

/// Event to add a new post with optimistic UI
class AddPost extends PostEvent {
  final String text;
  final String uid;

  const AddPost({required this.text, required this.uid});

  @override
  List<Object?> get props => [text, uid];
}

/// Event to load more posts (pagination)
class LoadMorePosts extends PostEvent {
  const LoadMorePosts();
}

/// Event when a post submission fails
class PostSubmissionFailed extends PostEvent {
  final String postId;

  const PostSubmissionFailed(this.postId);

  @override
  List<Object?> get props => [postId];
}
