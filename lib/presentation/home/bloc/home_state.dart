import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/post_entity.dart';

class HomeState extends Equatable {
  const HomeState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
  });

  final List<PostEntity> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DocumentSnapshot? lastDocument;

  HomeState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }

  @override
  List<Object?> get props => [posts, isLoading, hasMore, error, lastDocument];
}
