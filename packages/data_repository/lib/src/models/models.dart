import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// {@template hospital}
/// Hospital model
///
/// {@endtemplate}
class Hospital extends Equatable {
  ///{@macro hospital}
  const Hospital({required this.id, required this.name});

  /// The current hospital's name.
  final String name;

  /// The current hospital's id.
  final String id;

  @override
  List<Object?> get props => [name, id];

  static Hospital fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return Hospital(id: doc.id, name: data['name']);
    } else {
      throw Exception('Document does not exist');
    }
  }
}

class Survey extends Equatable {
  const Survey(
      {required this.id,
      required this.title,
      required this.numQuestions,
      required this.sections});

  final String id;
  final int numQuestions;
  final List<String> sections;
  final String title;

  static const inventory = Survey(
      id: 'XmEqxcSeXOPZRw3zPdjH',
      title: 'Safe Spine Survey',
      numQuestions: 207,
      sections: []);

  static const empty = Survey(id: '', title: '', numQuestions: 0, sections: []);

  bool get isEmpty => this == Survey.empty;

  bool get isNotEmpty => this != Survey.empty;
  @override
  List<Object?> get props => [id, numQuestions, sections, title];

  static Survey fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return Survey(
          id: doc.id,
          title: data['title'],
          numQuestions: data['numQuestions'],
          sections: data['sections'].map((e) => e.toString()).toList());
    } else {
      throw Exception('Document does not exist');
    }
  }

  Survey copyWith({
    String? id,
    String? title,
    int? numQuestions,
    List<String>? sections,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      numQuestions: numQuestions ?? this.numQuestions,
      sections: sections ?? this.sections,
    );
  }
}

class Section extends Equatable {
  const Section({required this.id, required this.questions});
  final String id;
  final List<String> questions;

  @override
  List<Object?> get props => [id, questions];

  static Section fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    print("converting snapshot to Section");
    if (data != null) {
      print(data['questions']);
      return Section(
          id: doc.id,
          questions: data['questions'].map((e) => e.toString()).toList());
    } else {
      throw Exception('Document does not exist');
    }
  }

  Map<String, dynamic> get json => {'questions': questions};

  Section copyWith({
    String? id,
    List<String>? questions,
  }) {
    return Section(
      id: id ?? this.id,
      questions: questions ?? this.questions,
    );
  }
}

class Question extends Equatable {
  const Question({required this.id, required this.info, required this.type});
  final String id;
  final String info;
  final String type;

  @override
  List<Object?> get props => [id, info, type];

  Map<String, dynamic> get json => {'info': info, 'type': type};

  static Question fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return Question(id: doc.id, info: data['info'], type: data['type']);
    } else {
      throw Exception('Document does not exist');
    }
  }
}

class GroupQuestion extends Question {
  const GroupQuestion(
      {required this.id, required this.info, required this.subquestions})
      : super(id: id, info: info, type: 'group');

  final List<String> subquestions;
  final String id;
  final String info;

  @override
  List<Object?> get props => [id, info, subquestions];

  @override
  Map<String, dynamic> get json =>
      {'info': info, 'type': 'group', 'subquestions': subquestions};

  static GroupQuestion fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return GroupQuestion(
          id: doc.id, info: data['info'], subquestions: data['subquestions']);
    } else {
      throw Exception('Document does not exist');
    }
  }
}

class BinaryQuestion extends Question {
  const BinaryQuestion(
      {required this.id,
      required this.info,
      required this.category,
      required this.level,
      required this.variable})
      : super(id: id, info: info, type: 'binary');

  final String category;
  final int level;
  final String variable;
  final String id;
  final String info;

  @override
  List<Object?> get props => [id, info, category, level, variable];

  @override
  Map<String, dynamic> get json => {
        'info': info,
        'type': 'binary',
        'category': category,
        'level': level,
        'variable': variable
      };

  static BinaryQuestion fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return BinaryQuestion(
          id: doc.id,
          info: data['info'],
          category: data['category'],
          level: data['level'],
          variable: data['variable']);
    } else {
      throw Exception('Document does not exist');
    }
  }
}

class Form extends Equatable {
  const Form(
      {required this.id,
      required this.title,
      this.dateStarted,
      this.dateReceived,
      this.dateCompleted,
      required this.surveyID,
      required this.hospitalID,
      required this.userID,
      required this.answers});

  final String id;
  final String title;
  final Map<String, String> answers;
  final DateTime? dateStarted;
  final DateTime? dateReceived;
  final DateTime? dateCompleted;
  final String surveyID;
  final String hospitalID;
  final String userID;

  static const empty = Form(
      id: '', title: '', surveyID: '', hospitalID: '', userID: '', answers: {});

  bool get isEmpty => this == Form.empty;

  bool get isNotEmpty => this != Form.empty;

  Form copyWith({
    String? id,
    String? title,
    Map<String, String>? answers,
    DateTime? dateStarted,
    DateTime? dateReceived,
    DateTime? dateCompleted,
    String? surveyID,
    String? hospitalID,
    String? userID,
  }) {
    return Form(
      id: id ?? this.id,
      title: title ?? this.title,
      answers: answers ?? this.answers,
      dateStarted: dateStarted ?? this.dateStarted,
      dateReceived: dateReceived ?? this.dateReceived,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      surveyID: surveyID ?? this.surveyID,
      hospitalID: hospitalID ?? this.hospitalID,
      userID: userID ?? this.userID,
    );
  }

  static Form fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data != null) {
      return Form(
          id: doc.id,
          title: data['title'],
          answers: data['answers'],
          surveyID: data['form_type'],
          hospitalID: data['hospital'],
          userID: data['user'],
          dateCompleted: (data['date_completed'] as Timestamp).toDate(),
          dateReceived: (data['date_received'] as Timestamp).toDate(),
          dateStarted: (data['date_started'] as Timestamp).toDate());
    } else {
      throw Exception('Document does not exist');
    }
  }

  Map<String, dynamic> get json => {
        'title': title,
        'answers': answers,
        'form_type': surveyID,
        'hospital': hospitalID,
        'user': userID,
        'date_completed':
            dateCompleted != null ? Timestamp.fromDate(dateCompleted!) : null,
        'date_received':
            dateReceived != null ? Timestamp.fromDate(dateReceived!) : null,
        'date_started':
            dateStarted != null ? Timestamp.fromDate(dateStarted!) : null,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        answers,
        dateStarted,
        dateReceived,
        dateCompleted,
        surveyID,
        hospitalID,
        userID
      ];
}
