import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/services/models.dart' as model;

class AppState with ChangeNotifier {
  static AppState? _instance;
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

  List<model.FormType> formats = [];
  Map<String, model.Section> sections = {};
  Map<String, model.Question> questions = {};
  List<model.Hospital> hospitals = [];
  List<model.Form> userForms = [];

  bool isLoading = true;

  User? get user => _auth.user;

  Future<void> refreshFromFirebase() async {
    print("Retrieving from firebase to state");

    if (AuthService().user != null) {
      formats = await service.getFormTypes();
      print("Retrieved formats");

      if (formats.isNotEmpty) {
        sections = {
          for (var v in await service.getSections(formats.first.id)) v.id: v
        };
        print("Retrieved sections");
        questions = {for (var v in await service.getQuestions()) v.id: v};
        print("Retrieved questions");
      }
      hospitals = await service.getHospitals();
      print("Retrieved hospitals");

      if (_auth.user != null) {
        userForms = await service.getForms(userId: _auth.user?.uid);
        print("Retrieved userforms");
      }

      print("Retrieved");

      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> updateForm(model.Form form) {
    return service.updateForm(form);
  }

  Future<void> submitForm(model.Form form) {
    return service.submitForm(form);
  }

  Future<void> addHospital(String hospitalName) async {
    await service.createHospital(hospitalName);
    hospitals = await service.getHospitals();
    notifyListeners();
    return;
  }

  //modify questions
  Future<void> modifyQuestion(String id, String newText) {
    return service.updateQuestion(id, newText);
  }

  Future<void> csv() async {
    await service.generateSpecificCSV();
    // await service.generateCSV();
    notifyListeners();
    return;
  }
}
