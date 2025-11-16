import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/firestore_service.dart';
import '../../core/services/uuid_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/create_post_use_case.dart';
import '../../domain/usecases/get_posts_page_use_case.dart';
import '../../domain/usecases/get_posts_stream_use_case.dart';
import '../../domain/usecases/get_uuid_use_case.dart';
import '../presentation/home/bloc/home_cubit.dart';

final getInstance = GetIt.instance;

class AppDependencies {
  static Future<void> initializeDependencies() async {
    // ---------------------------------------------------------------------
    // External Dependencies - Firebase
    // ---------------------------------------------------------------------
    getInstance.registerLazySingleton<FirebaseAuth>(
      () => FirebaseAuth.instance,
    );

    // ---------------------------------------------------------------------
    // Core Services
    // ---------------------------------------------------------------------
    getInstance.registerLazySingleton(
      () => FirestoreService(firestore: FirebaseFirestore.instance),
    );
    getInstance.registerLazySingleton(() => UuidService(uuid: const Uuid()));

    // ---------------------------------------------------------------------
    // Data Layer - Repositories
    // ---------------------------------------------------------------------
    getInstance.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        firestoreService: getInstance<FirestoreService>(),
      ),
    );

    // ---------------------------------------------------------------------
    // Domain Layer - Use Cases
    // ---------------------------------------------------------------------
    getInstance
        .registerLazySingleton(() => GetPostsStreamUseCase(getInstance()));
    getInstance.registerLazySingleton(() => GetPostsPageUseCase(getInstance()));
    getInstance.registerLazySingleton(() => CreatePostUseCase(getInstance()));
    getInstance.registerLazySingleton(() => GetUuidUseCase(getInstance()));

    // ---------------------------------------------------------------------
    // Presentation Layer - Cubits
    // ---------------------------------------------------------------------
    getInstance.registerFactory(
      () => HomeCubit(
        firebaseAuth: getInstance(),
        getPostsStreamUseCase: getInstance(),
        getPostsPageUseCase: getInstance(),
        createPostUseCase: getInstance(),
        getUuidUseCase: getInstance(),
      ),
    );
  }
}
