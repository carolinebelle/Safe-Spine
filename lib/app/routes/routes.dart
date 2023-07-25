import 'package:flutter/widgets.dart';
import 'package:safespine_bloc/app/app.dart';
import 'package:safespine_bloc/survey/survey.dart';
import 'package:safespine_bloc/login/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [SurveyView.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
