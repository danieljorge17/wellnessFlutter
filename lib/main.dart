import 'package:fe_testing_ta/app/app_dependencies.dart';
import 'package:fe_testing_ta/app/app_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppDependencies.initializeDependencies();

  await _logUser();

  runApp(const AppWidget());
}

Future<void> _logUser() async {
  final firebaseAuth = getInstance<FirebaseAuth>();

  if (firebaseAuth.currentUser == null) {
    try {
      await firebaseAuth.signInAnonymously();
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
    }
  }
}
