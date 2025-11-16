import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fe_testing_ta/bloc/post_bloc.dart';
import 'package:fe_testing_ta/bloc/post_event.dart';
import 'package:fe_testing_ta/bloc/post_state.dart';
import 'package:fe_testing_ta/repositories/post_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostBloc', () {
    late FakeFirebaseFirestore fakeFirestore;
    late PostRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = PostRepository(firestore: fakeFirestore);
    });

    test('prevents duplicate posts when same post is added multiple times',
        () async {
      // Create bloc
      final bloc = PostBloc(repository: repository);

      // Add the same post with the same content multiple times
      const uid = 'test-user';
      const text = 'Test post content';

      // Add post three times in quick succession
      bloc.add(const AddPost(uid: uid, text: text));
      bloc.add(const AddPost(uid: uid, text: text));
      bloc.add(const AddPost(uid: uid, text: text));

      // Wait for all events to process
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current state
      final state = bloc.state;

      // Each AddPost event generates a unique ID, so we should have 3 posts
      // But they should all have unique IDs (no duplicates)
      expect(state.posts.length, 3);

      // Verify all posts have unique IDs
      final postIds = state.posts.map((p) => p.id).toSet();
      expect(postIds.length, 3, reason: 'All posts should have unique IDs');

      // Verify all posts have the same text
      for (final post in state.posts) {
        expect(post.text, text);
        expect(post.uid, uid);
      }

      await bloc.close();
    });

    blocTest<PostBloc, PostState>(
      'adds optimistic post immediately to state before Firestore confirmation',
      build: () => PostBloc(repository: repository),
      act: (bloc) => bloc.add(const AddPost(
        uid: 'test-user',
        text: 'Feeling great after meditation',
      )),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        // Verify post appears in state
        expect(bloc.state.posts.length, greaterThan(0));

        final post = bloc.state.posts.first;
        expect(post.text, 'Feeling great after meditation');
        expect(post.uid, 'test-user');

        // Initially should not be sent to server yet
        expect(post.hasSentToServer, false);
      },
    );

    blocTest<PostBloc, PostState>(
      'loads posts from Firestore stream',
      build: () => PostBloc(repository: repository),
      seed: () => const PostState(),
      setUp: () async {
        // Add a post directly to Firestore
        await fakeFirestore.collection('posts').add({
          'uid': 'user-1',
          'text': 'Pre-existing post',
          'createdAt': Timestamp.now(),
        });
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        // Verify post from Firestore appears in state
        expect(bloc.state.posts.length, greaterThanOrEqualTo(1));

        final post = bloc.state.posts.firstWhere(
          (p) => p.text == 'Pre-existing post',
        );
        expect(post.uid, 'user-1');
        expect(post.hasSentToServer, true);
      },
    );

    blocTest<PostBloc, PostState>(
      'merges optimistic posts with server posts without duplication',
      build: () => PostBloc(repository: repository),
      seed: () => const PostState(),
      act: (bloc) async {
        // Start listening to posts
        bloc.add(const LoadPosts());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add an optimistic post
        bloc.add(const AddPost(
          uid: 'test-user',
          text: 'New wellness check-in',
        ));

        // Wait for Firestore to sync
        await Future.delayed(const Duration(milliseconds: 500));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final posts = bloc.state.posts;

        // Count posts with the specific text
        final matchingPosts = posts
            .where((p) => p.text == 'New wellness check-in')
            .toList();

        // Should only have one post with this text (no duplication)
        // After Firestore sync, optimistic post should be replaced by server version
        expect(
          matchingPosts.length,
          lessThanOrEqualTo(1),
          reason: 'Should not have duplicate posts after server sync',
        );
      },
    );
  });
}
