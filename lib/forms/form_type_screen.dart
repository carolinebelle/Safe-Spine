import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/services/models.dart';
import 'package:safespine/survey/survey.dart';

class FormTypeScreen extends StatefulWidget {
  final FormType form;

  const FormTypeScreen({super.key, required this.form});

  @override
  State<FormTypeScreen> createState() => _FormTypeScreenState();
}

class _FormTypeScreenState extends State<FormTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.form.title),
        ),
        body: StartSurvey(
            hospitals: Provider.of<AppState>(context).hospitals,
            form: widget.form));
  }
}

class StartSurvey extends StatefulWidget {
  final List<Hospital> hospitals;
  final FormType form;
  const StartSurvey({super.key, required this.hospitals, required this.form});

  @override
  State<StartSurvey> createState() => _StartSurveyState();
}

class _StartSurveyState extends State<StartSurvey> {
  Hospital? hospital;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select hospital: "),
        Center(
          child: DropdownButton(
            value: hospital,
            items: widget.hospitals
                .map((Hospital h) => DropdownMenuItem(
                      value: h,
                      child: Text(h.name),
                    ))
                .toList(),
            onChanged: (Hospital? newValue) {
              setState(() {
                hospital = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: hospital != null
              ? () {
                  // When the user taps the button,
                  // navigate to a named route and
                  // provide the arguments as an optional
                  // parameter.
                  Navigator.pushNamed(
                    context,
                    '/survey',
                    arguments: SurveyScreenArguments(widget.form, hospital!),
                  );
                }
              : null,
          child: const Text('Start Survey'),
        ),
      ],
    );
  }
}
