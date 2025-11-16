import 'package:fe_testing_ta/app/app_dependencies.dart';
import 'package:fe_testing_ta/presentation/home/bloc/home_cubit.dart';
import 'package:fe_testing_ta/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => getInstance<HomeCubit>()..loadPosts(),
        child: const HomePage(),
      ),
    );
  }
}
