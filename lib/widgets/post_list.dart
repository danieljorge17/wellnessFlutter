import 'package:flutter/material.dart';
import '../models/post.dart';
import 'post_card.dart';

class PostList extends StatefulWidget {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const PostList({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && widget.hasMore && !widget.isLoading) {
      widget.onLoadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Trigger at 90% scroll
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.posts.length + (widget.hasMore ? 1 : 0),
      // Use itemBuilder for better performance - only builds visible items
      itemBuilder: (context, index) {
        if (index >= widget.posts.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final post = widget.posts[index];
        // Use key to help Flutter identify items for efficient rebuilds
        return PostCard(
          key: ValueKey(post.id),
          post: post,
        );
      },
    );
  }
}
