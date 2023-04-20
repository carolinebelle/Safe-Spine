import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/services/models.dart' as m;

class AppState with ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AuthService _auth = AuthService();

  List<m.FormType> formats = [];
  Map<String, m.Section> sections = {};
  Map<String, m.Question> questions = {};
  List<m.Hospital> hospitals = [];
  List<m.Form> userForms = [];

  bool isLoading = true;

  User? get user => _auth.user;

  Future<void> refreshFromFirebase() async {
    print("Retrieving from firebase to state");

    if (AuthService().user != null) {
      formats = await _service.getFormTypes();
      print("Retrieved formats");

      if (formats.isNotEmpty) {
        sections = {
          for (var v in await _service.getSections(formats.first.id)) v.id: v
        };
        print("Retrieved sections");
        questions = {for (var v in await _service.getQuestions()) v.id: v};
        print("Retrieved questions");
      }
      hospitals = await _service.getHospitals();
      print("Retrieved hospitals");

      if (_auth.user != null) {
        userForms = await _service.getForms(userId: _auth.user?.uid);
        print("Retrieved userforms");
      }

      print("Retrieved");

      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> updateForm(m.Form form) {
    return _service.updateForm(form);
  }

  Future<void> submitForm(m.Form form) {
    return _service.submitForm(form);
  }

  Future<void> addHospital(String hospitalName) async {
    await _service.createHospital(hospitalName);
    hospitals = await _service.getHospitals();
    notifyListeners();
    return;
  }

  //modify questions
  Future<void> modifyQuestion(String id, String newText) {
    return _service.updateQuestion(id, newText);
  }

  Future<void> csv() async {
    await _service.generateSpecificCSV();
    // await _service.generateCSV();
    notifyListeners();
    return;
  }
}
