import 'package:authentication_repository/authentication_repository.dart';
import 'package:data_repository/data_repository.dart';
// import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/survey/bloc/survey_bloc.dart';

import '../../theme.dart';
// import '../routes/routes.dart';
import 'view.dart';

class SurveyView extends StatelessWidget {
  const SurveyView({super.key});

  static Page<void> page() => const MaterialPage<void>(child: SurveyView());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurveyBloc(
          dataRepository: context.read<DataRepository>(),
          authenticationRepository: context.read<AuthenticationRepository>())
        ..add(const SurveyViewStarted()),
      child: const SurveyPages(),
    );
  }
}

class SurveyPages extends StatelessWidget {
  const SurveyPages({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: BlocConsumer<SurveyBloc, SurveyState>(
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
          }
        },
        builder: (_, state) => state.status == SurveyStatus.unselected
            ? const SurveyOptionsPage()
            : const SurveyForm(),
      ),
    );
  }
}
