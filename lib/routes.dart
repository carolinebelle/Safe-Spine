import "package:safespine/about/about.dart";
import "package:safespine/forms/forms.dart";
import "package:safespine/history/history.dart";
import "package:safespine/home/home.dart";
import 'package:safespine/hospitals/add_hospital.dart';
import "package:safespine/login/login.dart";
import "package:safespine/survey/survey.dart";
import "package:safespine/signup/signup.dart";
import "package:safespine/csv/csv.dart";

import 'modifyQuestions/modify_questions.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/forms': (context) => const FormsScreen(),
  '/history': (context) => const HistoryScreen(),
  '/about': (context) => const AboutScreen(),
  '/survey': (context) => const SurveyScreen(),
  '/addHospital': (context) => const AddHospital(),
  '/csv': (context) => const CSV(),
  '/modifyQuestions': (context) => const ModifyQuestions(),
};
