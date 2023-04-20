// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormType _$FormTypeFromJson(Map<String, dynamic> json) => FormType(
      id: json['id'] as String? ?? '',
      numQuestions: json['numQuestions'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FormTypeToJson(FormType instance) => <String, dynamic>{
      'id': instance.id,
      'numQuestions': instance.numQuestions,
      'title': instance.title,
      'sections': instance.sections,
    };

Section _$SectionFromJson(Map<String, dynamic> json) => Section(
      id: json['id'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'id': instance.id,
      'questions': instance.questions,
    };

BinaryQuestion _$BinaryQuestionFromJson(Map<String, dynamic> json) =>
    BinaryQuestion(
      id: json['id'] as String? ?? '',
      info: json['info'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      variable: json['variable'] as String? ?? '',
    )..type = json['type'] as String;

Map<String, dynamic> _$BinaryQuestionToJson(BinaryQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'info': instance.info,
      'variable': instance.variable,
      'category': instance.category,
      'level': instance.level,
    };

GroupQuestion _$GroupQuestionFromJson(Map<String, dynamic> json) =>
    GroupQuestion(
      id: json['id'] as String? ?? '',
      info: json['info'] as String? ?? '',
      subquestions: (json['subquestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      variable: json['variable'] as String? ?? '',
    )..type = json['type'] as String;

Map<String, dynamic> _$GroupQuestionToJson(GroupQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'info': instance.info,
      'variable': instance.variable,
      'subquestions': instance.subquestions,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      employer: json['employer'] as String? ?? '',
      name: json['name'] as Map<String, dynamic>? ??
          const {"first": '', "last": ''},
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'isAdmin': instance.isAdmin,
      'employer': instance.employer,
      'name': instance.name,
    };

Hospital _$HospitalFromJson(Map<String, dynamic> json) => Hospital(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$HospitalToJson(Hospital instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
