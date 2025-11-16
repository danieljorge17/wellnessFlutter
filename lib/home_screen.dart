import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/post_bloc.dart';
import 'bloc/post_event.dart';
import 'bloc/post_state.dart';
import 'widgets/post_composer.dart';
import 'widgets/post_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Feed'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          return Column(
            children: [
              // Composer at the top
              PostComposer(
                onSubmit: (text) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    context.read<PostBloc>().add(
                          AddPost(text: text, uid: user.uid),
                        );
                  }
                },
              ),
              const Divider(height: 1),
              // Feed below
              Expanded(
                child: state.posts.isEmpty && !state.isLoading
                    ? const Center(
                        child: Text(
                          'No posts yet.\nBe the first to share!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : PostList(
                        posts: state.posts,
                        isLoading: state.isLoading,
                        hasMore: state.hasMore,
                        onLoadMore: () {
                          context.read<PostBloc>().add(const LoadMorePosts());
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
