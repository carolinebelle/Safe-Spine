import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/survey/survey.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    final userForms = context.select((SurveyBloc bloc) => bloc.state.forms);
    return Column(children: [
      userForms.isEmpty
          ? const Center(
              child: Text("No user forms, yet."),
            )
          : Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: userForms
                      .map((form) => FormListItem(form: form))
                      .toList(),
                ),
              ),
            )
    ]);
  }
}
