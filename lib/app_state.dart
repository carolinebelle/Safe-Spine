import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/services/models.dart' as model;

class AppState with ChangeNotifier {
  static AppState? _instance;

  //history.dart
  //complete_page.dart
  //survey.dart
  final FirestoreService service;

  final AuthService _auth = AuthService();

  static Future<AppState> getInstance() async {
    if (_instance == null) {
      final firestoreService = await FirestoreService.getInstance();
      _instance = AppState._(firestoreService);
    }
    return _instance!;
  }

  AppState._(this.service);

  //form_type_screen.dart to build widget
  //form_item.dart to build widget
  List<model.Hospital> hospitals = [];

  List<model.Form> userForms = [];

  //forms.dart TODO: potentially unnecessary
  bool isLoading = true;

  User? get user => _auth.user;

  //forms.dart postFrameCallback
  Future<void> refreshFromFirebase() async {
    print("Retrieving from firebase to state");

    if (AuthService().user != null) {
      List<model.FormType> formats =
          await service.getFormTypes(fromCache: false);
      print("Retrieved formats");

      if (formats.isNotEmpty) {
        await service.getSections(formats.first.id, fromCache: false);
        print("Retrieved sections");

        await service.getQuestions(fromCache: false);
        print("Retrieved questions");
      }
      hospitals = await service.getHospitals(fromCache: false);
      print("Retrieved hospitals");

      //TODO: only check relevant forms
      if (_auth.user != null) {
        userForms = await service.getForms(userId: _auth.user?.uid);
        print("Retrieved userforms");
      }

      print("Retrieved");

      isLoading = false;

      notifyListeners();
    }
  }

  //add_hospital.dart button action
  Future<void> addHospital(String hospitalName) async {
    await service.createHospital(hospitalName);
    hospitals = await service.getHospitals();
    notifyListeners();
    return;
  }

  //modify_questions.dart button action
  Future<void> modifyQuestion(String id, String newText) {
    return service.updateQuestion(id, newText);
  }

  //csv.dart button action
  Future<void> csv() async {
    await service.generateSpecificCSV();
    // await service.generateCSV();
    notifyListeners();
    return;
  }
}
