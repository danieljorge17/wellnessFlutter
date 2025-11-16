import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import 'widgets/post_composer.dart';
import 'widgets/post_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          return Column(
            children: [
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
                        onLoadMore: cubit.loadMorePosts,
                      ),
              ),
              const Divider(height: 1),
              PostComposer(
                onSubmit: cubit.addPost,
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
            ],
          );
        },
      ),
    );
  }
}
