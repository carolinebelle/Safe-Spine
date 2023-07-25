part of 'survey_bloc.dart';

enum CallStatus { initial, loading, success, failure }

enum SurveyStatus { unselected, selected }

final class SurveyState extends Equatable {
  const SurveyState._({
    this.status = SurveyStatus.unselected,
    this.callStatus = CallStatus.initial,
    this.form = Form.empty,
    this.survey = Survey.empty,
    List<Hospital>? hospitals,
    List<Form>? forms,
    List<Survey>? surveys,
    this.message = '',
  })  : forms = forms ?? const [],
        hospitals = hospitals ?? const [],
        surveys = surveys ?? const [];

  const SurveyState.loadingData()
      : this._(status: SurveyStatus.unselected, callStatus: CallStatus.loading);
  const SurveyState.loadingDataSuccess(
      List<Survey> surveys, List<Form> forms, List<Hospital> hospitals)
      : this._(
            status: SurveyStatus.unselected,
            callStatus: CallStatus.success,
            surveys: surveys,
            forms: forms,
            hospitals: hospitals);

  const SurveyState.loadingDataFailure(String message)
      : this._(
            status: SurveyStatus.unselected,
            callStatus: CallStatus.failure,
            message: message);

  SurveyState copyWith({
    SurveyStatus? status,
    CallStatus? callStatus,
    Survey? survey,
    Form? form,
    String? message,
    List<Form>? forms,
    List<Hospital>? hospitals,
    List<Survey>? surveys,
  }) {
    return SurveyState._(
      status: status ?? this.status,
      callStatus: callStatus ?? this.callStatus,
      survey: survey ?? this.survey,
      form: form ?? this.form,
      message: message ?? this.message,
      hospitals: hospitals ?? this.hospitals,
      forms: forms ?? this.forms,
      surveys: surveys ?? this.surveys,
    );
  }

  final SurveyStatus status;
  final CallStatus callStatus;
  final Survey survey;
  final Form form;
  final String message;
  final List<Hospital> hospitals;
  final List<Form> forms;
  final List<Survey> surveys;

  @override
  List<Object> get props => [status, survey, form, message, forms, surveys];
}
