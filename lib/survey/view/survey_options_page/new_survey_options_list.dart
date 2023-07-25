import 'package:flutter/material.dart';
import 'package:data_repository/data_repository.dart' as data_repo;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/survey/view/survey_options_page/view.dart';

import '../../bloc/survey_bloc.dart';

class NewSurveyOptionsList extends StatelessWidget {
  const NewSurveyOptionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final surveys = context.select((SurveyBloc bloc) => bloc.state.surveys);
    return Column(
      children: surveys.map((survey) => SurveyOption(survey: survey)).toList(),
    );
  }
}

class SurveyOption extends StatelessWidget {
  final data_repo.Survey survey;

  const SurveyOption({Key? key, required this.survey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(survey.title),
      onPressed: () {
        Navigator.of(context).push<void>(StartSurveyScreen.route());
        context.read<SurveyBloc>().add(NewFormStarted(survey));
      },
    );
  }
}
