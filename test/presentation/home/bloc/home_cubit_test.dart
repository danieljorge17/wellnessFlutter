import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fe_testing_ta/core/services/firestore_service.dart';
import 'package:fe_testing_ta/core/services/uuid_service.dart';
import 'package:fe_testing_ta/data/repositories/post_repository_impl.dart';
import 'package:fe_testing_ta/domain/usecases/create_post_use_case.dart';
import 'package:fe_testing_ta/domain/usecases/get_posts_page_use_case.dart';
import 'package:fe_testing_ta/domain/usecases/get_posts_stream_use_case.dart';
import 'package:fe_testing_ta/domain/usecases/get_uuid_use_case.dart';
import 'package:fe_testing_ta/presentation/home/bloc/home_cubit.dart';
import 'package:fe_testing_ta/presentation/home/bloc/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import '../../../mocks/general_mocks.dart';

void main() {
  group('HomeCubit', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late PostRepositoryImpl repository;
    late GetPostsStreamUseCase getPostsStreamUseCase;
    late GetPostsPageUseCase getPostsPageUseCase;
    late CreatePostUseCase createPostUseCase;
    late GetUuidUseCase getUuidUseCase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);

      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('test-user-id');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      repository = PostRepositoryImpl(firestoreService: firestoreService);
      getPostsStreamUseCase = GetPostsStreamUseCase(repository);
      getPostsPageUseCase = GetPostsPageUseCase(repository);
      createPostUseCase = CreatePostUseCase(repository);
      getUuidUseCase = GetUuidUseCase(UuidService(uuid: const Uuid()));
    });

    HomeCubit createCubit() {
      return HomeCubit(
        firebaseAuth: mockFirebaseAuth,
        getPostsStreamUseCase: getPostsStreamUseCase,
        getPostsPageUseCase: getPostsPageUseCase,
        createPostUseCase: createPostUseCase,
        getUuidUseCase: getUuidUseCase,
      );
    }

    test(
        'should prevent duplicate posts when same post is added multiple times',
        () async {
      final cubit = createCubit();

      const text = 'Test post content';

      cubit.addPost(text: text);
      cubit.addPost(text: text);
      cubit.addPost(text: text);

      await Future.delayed(const Duration(milliseconds: 500));

      final state = cubit.state;

      expect(state.posts.length, 3);

      final postIds = state.posts.map((p) => p.id).toSet();
      expect(postIds.length, 3, reason: 'All posts should have unique IDs');

      for (final post in state.posts) {
        expect(post.text, text);
        expect(post.uid, 'test-user-id');
      }

      await cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'should add optimistic post immediately to state before Firestore confirmation',
      build: createCubit,
      act: (cubit) => cubit.addPost(
        text: 'Feeling great after meditation',
      ),
      wait: const Duration(milliseconds: 100),
      verify: (cubit) {
        expect(cubit.state.posts.length, greaterThan(0));

        final post = cubit.state.posts.first;
        expect(post.text, 'Feeling great after meditation');
        expect(post.uid, 'test-user-id');

        expect(post.hasSentToServer, false);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'should load posts from Firestore stream',
      build: createCubit,
      seed: () => const HomeState(),
      setUp: () async {
        await fakeFirestore.collection('posts').add({
          'uid': 'user-1',
          'text': 'Pre-existing post',
          'createdAt': Timestamp.now(),
        });
      },
      act: (cubit) => cubit.loadPosts(),
      wait: const Duration(milliseconds: 500),
      verify: (cubit) {
        expect(cubit.state.posts.length, greaterThanOrEqualTo(1));

        final post = cubit.state.posts.firstWhere(
          (p) => p.text == 'Pre-existing post',
        );
        expect(post.uid, 'user-1');
        expect(post.hasSentToServer, true);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'should merge optimistic posts with server posts without duplication',
      build: createCubit,
      seed: () => const HomeState(),
      act: (cubit) async {
        cubit.loadPosts();
        await Future.delayed(const Duration(milliseconds: 100));

        cubit.addPost(
          text: 'New wellness check-in',
        );

        await Future.delayed(const Duration(milliseconds: 500));
      },
      wait: const Duration(milliseconds: 200),
      verify: (cubit) {
        final posts = cubit.state.posts;

        final matchingPosts =
            posts.where((p) => p.text == 'New wellness check-in').toList();

        expect(
          matchingPosts.length,
          lessThanOrEqualTo(1),
          reason: 'Should not have duplicate posts after server sync',
        );
      },
    );
  });
}
