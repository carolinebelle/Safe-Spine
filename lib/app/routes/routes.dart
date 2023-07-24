import 'package:flutter/widgets.dart';
import 'package:safespine_bloc/app/app.dart';
import 'package:safespine_bloc/home/home.dart';
import 'package:safespine_bloc/login/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
