import 'package:json_annotation/json_annotation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

part 'models.g.dart';

class Form {
  String id;
  Map<String, String> answers;
  Timestamp? dateCompleted;
  Timestamp? dateReceived;
  Timestamp? dateStarted;
  // ignore: non_constant_identifier_names
  String form_type;
  String hospital;
  String title;
  String user;

  Form(
      {this.id = '',
      Map<String, String>? answers,
      this.dateCompleted,
      this.dateStarted,
      this.dateReceived,
      // ignore: non_constant_identifier_names
      this.form_type = '',
      this.hospital = '',
      this.title = '',
      this.user = ''})
      : answers = answers ?? {};

  static Form fromMap(Map<String, dynamic> map) {
    final Timestamp? dateCompleted;
    if (map['dateCompleted'] == null) {
      dateCompleted = null;
    } else {
      dateCompleted =
          Timestamp.fromMicrosecondsSinceEpoch(map['dateCompleted']);
    }

    final Timestamp? dateStarted;
    if (map['dateStarted'] == null) {
      dateStarted = null;
    } else {
      dateStarted = Timestamp.fromMicrosecondsSinceEpoch(map['dateStarted']);
    }

    final Timestamp? dateReceived;
    if (map['dateReceived'] == null) {
      dateReceived = null;
    } else {
      dateReceived = Timestamp.fromMicrosecondsSinceEpoch(map['dateReceived']);
    }

    return Form(
        id: map['id'],
        dateCompleted: dateCompleted,
        dateReceived: dateReceived,
        dateStarted: dateStarted,
        form_type: map['form_type'],
        hospital: map['hospital'],
        title: map['title'],
        user: map['user']);
  }

  List<Map<String, String>> answersToMap() {
    final List<Map<String, String>> list = [];

    answers.forEach((key, value) {
      final Map<String, String> map = {
        'formID': id,
        'questionID': key,
        'response': value
      };
      list.add(map);
    });

    return list;
  }

  Map<String, dynamic> metadataToMap() {
    final Map<String, dynamic> map = {
      'id': id,
      'form_type': form_type,
      'hospital': hospital,
      'title': title,
      'user': user
    };

    if (dateStarted != null) {
      map['dateStarted'] = dateStarted?.microsecondsSinceEpoch;
    }
    if (dateCompleted != null) {
      map['dateCompleted'] = dateCompleted?.microsecondsSinceEpoch;
    }
    if (dateReceived != null) {
      map['dateReceived'] = dateReceived?.microsecondsSinceEpoch;
    }

    return map;
  }

  @override
  String toString() {
    return 'Form{id: $id, user: $user, hospital: $hospital, dateStarted: $dateStarted, dateCompleted: $dateCompleted, answers: n = ${answers.length}}';
  }
}

@JsonSerializable()
class FormType {
  String id;
  int numQuestions;
  String title;
  List<String> sections;
  FormType(
      {this.id = '',
      this.numQuestions = 0,
      this.title = '',
      this.sections = const []});
  factory FormType.fromJson(String id, Map<String, dynamic> json) {
    return _$FormTypeFromJson(json..["id"] = id);
  }
  Map<String, dynamic> toJson() => _$FormTypeToJson(this)..remove("id");
}

@JsonSerializable()
class Section {
  String id;
  List<String> questions;

  Section({this.id = '', this.questions = const []});
  factory Section.fromJson(String id, Map<String, dynamic> json) =>
      _$SectionFromJson(json..["id"] = id);
  Map<String, dynamic> toJson() => _$SectionToJson(this)..remove("id");
}

class Question {
  String type;
  String id;
  String info;
  String variable;

  Question({this.type = '', this.id = '', this.info = '', this.variable = ''});
}

@JsonSerializable()
class BinaryQuestion extends Question {
  String category;
  int level;

  BinaryQuestion(
      {String id = '',
      String info = '',
      this.category = '',
      this.level = 0,
      String variable = ''})
      : super(type: 'binary', id: id, info: info, variable: variable);

  factory BinaryQuestion.fromJson(String id, Map<String, dynamic> json) =>
      _$BinaryQuestionFromJson(json..["id"] = id);
  Map<String, dynamic> toJson() => _$BinaryQuestionToJson(this)..remove("id");
}

@JsonSerializable()
class GroupQuestion extends Question {
  List<String> subquestions;
  GroupQuestion(
      {String id = '',
      String info = '',
      this.subquestions = const [],
      String variable = ''})
      : super(type: 'group', id: id, info: info, variable: variable);
  factory GroupQuestion.fromJson(String id, Map<String, dynamic> json) =>
      _$GroupQuestionFromJson(json..["id"] = id);
  Map<String, dynamic> toJson() => _$GroupQuestionToJson(this)..remove("id");
}

@JsonSerializable()
class User {
  String id;
  bool isAdmin;
  String employer;
  Map name;

  User(
      {this.id = '',
      this.isAdmin = false,
      this.employer = '',
      this.name = const {"first": '', "last": ''}});
  factory User.fromJson(String id, Map<String, dynamic> json) =>
      _$UserFromJson(json..["id"] = id);
  Map<String, dynamic> toJson() => _$UserToJson(this)..remove("id");
}

@JsonSerializable()
class Hospital {
  String id;
  String name;
  Hospital({this.id = '', this.name = ''});
  factory Hospital.fromJson(String id, Map<String, dynamic> json) =>
      _$HospitalFromJson(json..["id"] = id);
  Map<String, dynamic> toJson() => _$HospitalToJson(this)..remove("id");
}
