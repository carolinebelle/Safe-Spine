import 'dart:async';

import 'package:data_repository/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;

abstract class DataRepositoryInterface {
  Future<List<Hospital>> hospitals();
  Future<List<Form>> forms(String userID);
  Future<List<Question>> questions();
  Future<List<Survey>> surveys();
  Future<Question> question(String questionID);
  Future<bool> isAdmin(String userID);
  Future<void> addHospital(Hospital hospital);
  Future<void> deleteHospital(Hospital hospital);
  Future<void> modifyHospital(Hospital hospital);
  Future<Form> retrieveForm(String formID);
  Future<Form> createForm(String userID, Hospital hospital, Survey survey);
  Future<void> saveForm(Form form);
  Future<void> submitForm(Form form);
  Future<Survey> survey(String surveyID);
  Future<void> addSection(Section section);
  Future<void> deleteSection(Section section);
  Future<void> modifySection(Section section);
  Future<void> deleteQuestion(Question question);
  Future<void> modifyQuestion(Question question);
  Future<void> addQuestion(Question question, GroupQuestion? groupQuestion);
  Future<Hospital> hospital(String hospitalID);
  Future<void> deleteForm(Form form);
}

class GetHospitalsFailure implements Exception {
  const GetHospitalsFailure([this.message = 'An unknown exception occurred.']);

  factory GetHospitalsFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const GetHospitalsFailure('Permission denied');
      default:
        return const GetHospitalsFailure();
    }
  }

  ///The associated error message.
  final String message;
}

class AddHospitalFailure implements Exception {
  const AddHospitalFailure([this.message = 'An unknown exception occurred.']);

  factory AddHospitalFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const AddHospitalFailure('Permission denied');
      default:
        return const AddHospitalFailure();
    }
  }

  ///The associated error message.
  final String message;
}

class DeleteHospitalFailure implements Exception {
  const DeleteHospitalFailure(
      [this.message = 'An unknown exception occurred.']);

  factory DeleteHospitalFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const DeleteHospitalFailure('Permission denied');
      default:
        return const DeleteHospitalFailure();
    }
  }

  ///The associated error message.
  final String message;
}

class ModifyHospitalFailure implements Exception {
  const ModifyHospitalFailure(
      [this.message = 'An unknown exception occurred.']);

  factory ModifyHospitalFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const ModifyHospitalFailure('Permission denied');
      default:
        return const ModifyHospitalFailure();
    }
  }

  ///The associated error message.
  final String message;
}

/// {@template data_repository}
/// Repository which manages shared and local data.
/// {@endtemplate}
class DataRepository implements DataRepositoryInterface {
  /// {@macro data_repository}
  DataRepository({
    cloud_firestore.FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? cloud_firestore.FirebaseFirestore.instance {
    _configureCache();
  }

  final cloud_firestore.FirebaseFirestore _firestore;

  void _configureCache() {
    _firestore.settings = cloud_firestore.Settings(
      persistenceEnabled: true,
      cacheSizeBytes: cloud_firestore.Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Stream of [Hospital] which will emit new values when the
  /// database is updated
  Future<List<Hospital>> hospitals() async {
    try {
      final cloud_firestore.QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('hospitals').get();
      final List<Hospital> hospitals = snapshot.docs
          .map((doc) => Hospital(id: doc.id, name: doc.data()['name']))
          .toList();
      return hospitals;
    } on cloud_firestore.FirebaseException catch (e) {
      throw GetHospitalsFailure.fromCode(e.code);
    } catch (e) {
      throw const GetHospitalsFailure();
    }
  }

  Future<List<Form>> forms(String userID) async {
    final cloud_firestore.QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('forms')
            .where('user', isEqualTo: userID)
            .get();
    final List<Form> forms = snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      return Form(
          id: doc.id,
          title: data['title'],
          dateStarted:
              (data['dateStarted'] as cloud_firestore.Timestamp).toDate(),
          dateReceived:
              (data['dateReceived'] as cloud_firestore.Timestamp).toDate(),
          dateCompleted:
              (data['dateCompleted'] as cloud_firestore.Timestamp).toDate(),
          surveyID: data['form_type'],
          hospitalID: data['hospital'],
          userID: data['user'],
          answers: data['answers'] as Map<String, String>);
    }).toList();
    return forms;
  }

  Future<bool> isAdmin(String userID) async {
    try {
      final result = await _firestore.collection('users').doc(userID).get();
      if (result.exists) {
        return result.data()?['admin'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> addHospital(Hospital hospital) async {
    try {
      await _firestore.collection('hospitals').add({'name': hospital.name});
    } on cloud_firestore.FirebaseException catch (e) {
      throw AddHospitalFailure.fromCode(e.code);
    } catch (e) {
      throw const AddHospitalFailure();
    }
  }

  Future<void> deleteHospital(Hospital hospital) async {
    try {
      await _firestore.collection('hospitals').doc(hospital.id).delete();
    } on cloud_firestore.FirebaseException catch (e) {
      throw DeleteHospitalFailure.fromCode(e.code);
    } catch (e) {
      throw const DeleteHospitalFailure();
    }
    ;
  }

  Future<void> modifyHospital(Hospital hospital) async {
    try {
      await _firestore
          .collection('hospitals')
          .doc(hospital.id)
          .update({'name': hospital.name});
    } on cloud_firestore.FirebaseException catch (e) {
      throw ModifyHospitalFailure.fromCode(e.code);
    } catch (e) {
      throw const ModifyHospitalFailure();
    }
    ;
  }

  @override
  Future<void> addQuestion(Question question, GroupQuestion? groupQuestion) {
    // TODO: implement addQuestion
    throw UnimplementedError();
  }

  @override
  Future<void> addSection(Section section) {
    // TODO: implement addSection
    throw UnimplementedError();
  }

  @override
  Future<void> deleteQuestion(Question question) {
    // TODO: implement deleteQuestion
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSection(Section section) {
    // TODO: implement deleteSection
    throw UnimplementedError();
  }

  @override
  Future<void> modifyQuestion(Question question) {
    // TODO: implement modifyQuestion
    throw UnimplementedError();
  }

  @override
  Future<void> modifySection(Section section) {
    // TODO: implement modifySection
    throw UnimplementedError();
  }

  @override
  Future<Question> question(String questionID) {
    // TODO: implement question
    throw UnimplementedError();
  }

  @override
  Future<List<Question>> questions() {
    // TODO: implement questions
    throw UnimplementedError();
  }

  @override
  Future<void> saveForm(Form form) {
    // TODO: implement saveForm
    throw UnimplementedError();
  }

  @override
  Future<void> submitForm(Form form) {
    // TODO: implement submitForm
    throw UnimplementedError();
  }

  @override
  Future<List<Survey>> surveys() {
    // TODO: implement surveys
    throw UnimplementedError();
  }

  @override
  Future<Form> createForm(String userID, Hospital hospital, Survey survey) {
    // TODO: implement createForm
    throw UnimplementedError();
  }

  @override
  Future<Form> retrieveForm(String formID) {
    // TODO: implement retrieveForm
    throw UnimplementedError();
  }

  @override
  Future<Survey> survey(String surveyID) {
    // TODO: implement survey
    throw UnimplementedError();
  }

  @override
  Future<Hospital> hospital(String hospitalID) {
    // TODO: implement hospital
    throw UnimplementedError();
  }

  @override
  Future<void> deleteForm(Form form) {
    // TODO: implement deleteForm
    throw UnimplementedError();
  }
}
