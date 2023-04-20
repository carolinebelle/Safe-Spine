import 'package:flutter/material.dart';
import 'package:safespine/forms/forms.dart';
import 'package:safespine/shared/error.dart';
import 'package:safespine/login/login.dart';
import 'package:safespine/services/auth.dart';
import '../shared/loading.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return const Center(
            child: ErrorMessage(),
          );
        } else if (snapshot.hasData) {
          return const FormsScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
