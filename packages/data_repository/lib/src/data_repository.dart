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
  Future<Section> getSection(String sectionID, {Survey survey});
  Future<void> addSection(Section section, {Survey survey});
  Future<void> deleteSection(Section section, {Survey survey});
  Future<void> modifySection(Section section, {Survey survey});
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
        return result.data()?['isAdmin'] ?? false;
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

/**
 * GroupQuestion? should have order subquestions with the new question already 
 * added to the list
 */
  @override
  Future<void> addQuestion(
      Question question, GroupQuestion? groupQuestion) async {
    try {
      Map<String, dynamic> data = question.json;
      await _firestore.collection('questions').doc(question.id).set(data);

      if (groupQuestion != null) {
        await _firestore
            .collection('questions')
            .doc(groupQuestion.id)
            .set(groupQuestion.json);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> addSection(Section section,
      {Survey survey = Survey.inventory}) async {
    try {
      await _firestore
          .collection('form_types')
          .doc(survey.id)
          .collection('Sections')
          .doc(section.id)
          .set({'questions': section.questions});
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> deleteQuestion(Question question) async {
    try {
      await _firestore.collection('questions').doc(question.id).delete();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> deleteSection(Section section,
      {Survey survey = Survey.inventory}) async {
    try {
      return await _firestore
          .collection('form_types')
          .doc(survey.id)
          .collection('Sections')
          .doc(section.id)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> modifyQuestion(Question question) async {
    try {
      Map<String, dynamic> data = question.json;
      await _firestore.collection('questions').doc(question.id).update(data);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> modifySection(Section section,
      {Survey survey = Survey.inventory}) async {
    try {
      return await _firestore
          .collection('form_types')
          .doc(survey.id)
          .collection('Sections')
          .doc(section.id)
          .update(section.json);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Question> question(String questionID) async {
    try {
      final doc =
          await _firestore.collection('questions').doc(questionID).get();
      final data = doc.data();
      if (data != null) {
        if (data['type'] == 'group') {
          return GroupQuestion(
              id: doc.id,
              info: data['info'],
              subquestions: data['subquestions'] as List<String>);
        } else {
          return BinaryQuestion(
              id: doc.id,
              info: data['info'],
              category: data['category'],
              level: data['level'],
              variable: data['variable']);
        }
      } else {
        throw Exception("Question $questionID not found");
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Question>> questions() async {
    return await _firestore
        .collection('questions')
        .get()
        .then((value) => value.docs.map((e) {
              final data = e.data();
              if (data['type'] == 'group') {
                return GroupQuestion(
                    id: e.id,
                    info: data['info'],
                    subquestions: data['subquestions']);
              } else {
                return BinaryQuestion(
                    id: e.id,
                    info: data['info'],
                    category: data['category'],
                    level: data['level'],
                    variable: data['variable']);
              }
            }).toList());
  }

  @override
  Future<void> saveForm(Form form) async {
    try {
      await _firestore
          .collection('forms')
          .doc(form.id)
          .update({'answers': form.answers});
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> submitForm(Form form) {
    DateTime dateCompleted = DateTime.now();
    try {
      return _firestore.collection('forms').doc(form.id).update({
        'dateCompleted': cloud_firestore.Timestamp.fromDate(dateCompleted),
        'dateReceived': cloud_firestore.FieldValue.serverTimestamp(),
        'answers': form.answers
      });
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Survey>> surveys() async {
    return await _firestore
        .collection('form_types')
        .get()
        .then((value) => value.docs.map((e) {
              return Survey.fromSnapshot(e);
            }).toList());
  }

  @override
  Future<Form> createForm(
      String userID, Hospital hospital, Survey survey) async {
    DateTime now = DateTime.now();
    try {
      final title = '${hospital.name}: ${now.year}-${now.month}-${now.day}';
      final data = {
        'user': userID,
        'hospital': hospital.id,
        'form_type': survey.id,
        'dateStarted': cloud_firestore.Timestamp.fromDate(now),
        'title': title,
        'answers': {}
      };
      final doc = await _firestore.collection('forms').add(data);
      return Form(
          id: doc.id,
          userID: userID,
          hospitalID: hospital.id,
          surveyID: survey.id,
          title: title,
          dateStarted: now,
          answers: {});
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Form> retrieveForm(String formID) async {
    try {
      final doc = await _firestore.collection("forms").doc(formID).get();
      final data = doc.data();
      if (data != null) {
        return Form(
            answers: data["answers"],
            id: formID,
            title: data["title"],
            dateStarted:
                (data["dateStarted"] as cloud_firestore.Timestamp).toDate(),
            dateReceived:
                (data["dateReceived"] as cloud_firestore.Timestamp).toDate(),
            dateCompleted:
                (data["dateCompleted"] as cloud_firestore.Timestamp).toDate(),
            surveyID: data["form_type"],
            hospitalID: data["hospital"],
            userID: data["user"]);
      } else {
        throw Exception("Form $formID not found");
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Survey> survey(String surveyID) async {
    try {
      final doc = await _firestore.collection('form_types').doc(surveyID).get();
      return Survey.fromSnapshot(doc);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Hospital> hospital(String hospitalID) async {
    return await _firestore
        .collection("hospitals")
        .doc(hospitalID)
        .get()
        .then((doc) {
      final data = doc.data();
      if (data != null) {
        return Hospital(id: doc.id, name: data["name"]);
      } else {
        throw Exception("Hospital $hospitalID not found");
      }
    });
  }

  @override
  Future<void> deleteForm(Form form) async {
    return await _firestore.collection('forms').doc(form.id).delete();
  }

  @override
  Future<Section> getSection(String sectionID,
      {Survey survey = Survey.inventory}) async {
    try {
      final cloud_firestore.DocumentSnapshot<Map<String, dynamic>> sectionDoc =
          await _firestore
              .collection('form_types')
              .doc(survey.id)
              .collection('Sections')
              .doc(sectionID)
              .get();

      print("RETRIEVED SECTION ${sectionDoc.data()}");
      return Section.fromSnapshot(sectionDoc);
    } catch (e) {
      throw e;
    }
  }
}
