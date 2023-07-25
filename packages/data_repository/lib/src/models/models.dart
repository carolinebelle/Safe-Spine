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
}

class Survey extends Equatable {
  const Survey(
      {required this.id,
      required this.title,
      required this.numQuestions,
      required this.sections});

  final String id;
  final int numQuestions;
  final List<Section> sections;
  final String title;

  static const empty =
      Survey(id: '', title: '', numQuestions: 0, sections: <Section>[]);

  bool get isEmpty => this == Survey.empty;

  bool get isNotEmpty => this != Survey.empty;
  @override
  List<Object?> get props => [id, numQuestions, sections, title];
}

class Section extends Equatable {
  const Section({required this.id, required this.questions});
  final String id;
  final List<String> questions;

  @override
  List<Object?> get props => [id, questions];
}

class Question extends Equatable {
  const Question({required this.id, required this.info});
  final String id;
  final String info;

  @override
  List<Object?> get props => [id, info];
}

class GroupQuestion extends Question {
  const GroupQuestion(
      {required this.id, required this.info, required this.subquestions})
      : super(id: id, info: info);

  final List<String> subquestions;
  final String id;
  final String info;

  @override
  List<Object?> get props => [id, info, subquestions];
}

class BinaryQuestion extends Question {
  const BinaryQuestion(
      {required this.id,
      required this.info,
      required this.category,
      required this.level,
      required this.variable})
      : super(id: id, info: info);

  final String category;
  final int level;
  final String variable;
  final String id;
  final String info;

  @override
  List<Object?> get props => [id, info, category, level, variable];
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
