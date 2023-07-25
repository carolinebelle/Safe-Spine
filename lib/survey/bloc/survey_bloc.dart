import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:data_repository/data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'survey_event.dart';
part 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  SurveyBloc(
      {required DataRepository dataRepository,
      required AuthenticationRepository authenticationRepository})
      : _dataRepository = dataRepository,
        _authenticationRepository = authenticationRepository,
        super(const SurveyState._()) {
    on<SurveyViewStarted>(_onSurveyViewStarted);
    on<NewFormStarted>(_onNewFormStarted);
    on<HospitalSelected>(_onHospitalSelected);
    on<FormSelected>(_onFormSelected);
    on<FormSubmitted>(_onFormSubmitted);
    on<FormDeselected>(_onFormDeselected);
    on<FormSaved>(_onFormSaved);
    on<FormDeleted>(_onFormDeleted);
    on<MessageAcknowledged>(_onMessageAcknowledged);
  }

  final DataRepository _dataRepository;
  final AuthenticationRepository _authenticationRepository;

  void _onSurveyViewStarted(
      SurveyEvent event, Emitter<SurveyState> emit) async {
    emit(const SurveyState.loadingData());
    try {
      List<Survey> surveys = await _dataRepository.surveys();
      List<Form> forms =
          await _dataRepository.forms(_authenticationRepository.currentUser.id);
      List<Hospital> hospitals = await _dataRepository.hospitals();
      List<Question> questions = await _dataRepository.questions();
      emit(SurveyState.loadingDataSuccess(surveys, forms, hospitals));
    } catch (e) {
      emit(SurveyState.loadingDataFailure(e.toString()));
    }
  }

  void _onNewFormStarted(
      NewFormStarted event, Emitter<SurveyState> emit) async {
    emit(state.copyWith(survey: event.survey, form: Form.empty));
  }

  Future<void> _onHospitalSelected(
      HospitalSelected event, Emitter<SurveyState> emit) async {
    emit(state.copyWith(callStatus: CallStatus.loading, form: Form.empty));
    try {
      Form newForm = await _dataRepository.createForm(
          _authenticationRepository.currentUser.id,
          event.hospital,
          state.survey);
      emit(state.copyWith(
          status: SurveyStatus.selected,
          callStatus: CallStatus.success,
          form: newForm));
    } catch (e) {
      emit(state.copyWith(
          callStatus: CallStatus.failure, message: e.toString()));
    }
  }

  void _onFormSelected(FormSelected event, Emitter<SurveyState> emit) async {
    if (event.form.dateReceived != null) {
      emit(state.copyWith(callStatus: CallStatus.loading));
      //already submitted a version so duplicate
      try {
        Hospital hospital =
            await _dataRepository.hospital(event.form.hospitalID);
        Survey survey = await _dataRepository.survey(event.form.surveyID);
        Form newForm = await _dataRepository.createForm(
            _authenticationRepository.currentUser.id, hospital, survey);
        Form copyForm = newForm.copyWith(answers: event.form.answers);
        emit(state.copyWith(
          status: SurveyStatus.selected,
          callStatus: CallStatus.success,
          survey: survey,
          form: copyForm,
        ));
      } catch (e) {
        emit(state.copyWith(
            callStatus: CallStatus.failure, message: e.toString()));
      }
    } else {
      emit(state.copyWith(callStatus: CallStatus.loading));
      try {
        Survey survey = await _dataRepository.survey(event.form.surveyID);
        emit(state.copyWith(
            status: SurveyStatus.selected,
            callStatus: CallStatus.success,
            survey: survey,
            form: event.form));
      } catch (e) {
        emit(state.copyWith(
            callStatus: CallStatus.failure, message: e.toString()));
      }
    }
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<SurveyState> emit) async {
    emit(state.copyWith(callStatus: CallStatus.loading));

    try {
      await _dataRepository.submitForm(event.form);
      emit(state.copyWith(callStatus: CallStatus.success, form: event.form));
    } catch (e) {
      emit(state.copyWith(
          callStatus: CallStatus.failure, message: e.toString()));
    }
  }

  void _onFormDeselected(FormDeselected event, Emitter<SurveyState> emit) {
    emit(state.copyWith(
        status: SurveyStatus.unselected,
        callStatus: CallStatus.initial,
        form: Form.empty,
        survey: Survey.empty,
        message: ''));
  }

  Future<void> _onFormSaved(FormSaved event, Emitter<SurveyState> emit) async {
    emit(state.copyWith(callStatus: CallStatus.loading));
    try {
      final DateTime now = DateTime.now();
      await _dataRepository.saveForm(event.form);
      emit(state.copyWith(
          callStatus: CallStatus.success,
          form: event.form,
          message:
              "Form saved on ${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute}."));
    } catch (e) {
      emit(state.copyWith(
          callStatus: CallStatus.failure, message: e.toString()));
    }
  }

  void _onMessageAcknowledged(
      MessageAcknowledged event, Emitter<SurveyState> emit) {
    emit(state.copyWith(callStatus: CallStatus.initial, message: ''));
  }

  Future<void> _onFormDeleted(
      FormDeleted event, Emitter<SurveyState> emit) async {
    emit(state.copyWith(callStatus: CallStatus.loading));
    try {
      await _dataRepository.deleteForm(event.form);
      emit(state.copyWith(
          status: SurveyStatus.unselected,
          callStatus: CallStatus.success,
          form: Form.empty,
          survey: Survey.empty,
          message: 'Form deleted.'));
    } catch (e) {
      emit(state.copyWith(
          callStatus: CallStatus.failure, message: e.toString()));
    }
  }
}
