part of 'survey_bloc.dart';

sealed class SurveyEvent {
  const SurveyEvent();
}

final class SurveyViewStarted extends SurveyEvent {
  const SurveyViewStarted();
}

final class NewFormStarted extends SurveyEvent {
  const NewFormStarted(this.survey);

  final Survey survey;
}

final class HospitalSelected extends SurveyEvent {
  const HospitalSelected(this.hospital);

  final Hospital hospital;
}

final class FormSelected extends SurveyEvent {
  const FormSelected(this.form);

  final Form form;
}

final class FormSubmitted extends SurveyEvent {
  const FormSubmitted(this.form);

  final Form form;
}

final class FormDeselected extends SurveyEvent {
  const FormDeselected(this.form);

  final Form form;
}

final class FormSaved extends SurveyEvent {
  const FormSaved(this.form);

  final Form form;
}

final class FormPaused extends SurveyEvent {
  const FormPaused(this.form);

  final Form form;
}

final class FormDeleted extends SurveyEvent {
  const FormDeleted(this.form);

  final Form form;
}

final class MessageAcknowledged extends SurveyEvent {
  const MessageAcknowledged();
}
