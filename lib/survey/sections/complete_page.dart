import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/shared/loading.dart';
import 'package:safespine/survey/survey_state.dart';
import 'package:safespine/shared/progress.dart';
import 'package:safespine/app_state.dart';

class CompletePage extends StatefulWidget {
  final int sectionIndex;
  const CompletePage({super.key, required this.sectionIndex});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  bool loading = false;
  bool submitted = false;
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<SurveyState>(context);
    final appState = Provider.of<AppState>(context);
    final FirestoreService service = appState.service;

    void submitForm(BuildContext context) async {
      setState(() {
        loading = true;
      });
      await service.submitForm(state.form);
      setState(() {
        loading = false;
        submitted = true;
      });
      if (!mounted) return;
      Navigator.of(context).pop();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Summary"),
          leading: widget.sectionIndex > 0 && !submitted
              ? Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      state.previousSection();
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      size: 26.0,
                    ),
                  ),
                )
              : null,
          automaticallyImplyLeading: false,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "${state.form.answers.length} / ${state.format.numQuestions}"),
              const SizedBox(height: 20),
              AnimatedProgressbar(
                  value: state.form.answers.length / state.format.numQuestions),
              const SizedBox(height: 20),
              submitted
                  ? TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Exit'),
                    )
                  : ElevatedButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: state.form.answers.length ==
                                  state.format.numQuestions &&
                              !loading &&
                              !submitted
                          ? () {
                              submitForm(context);
                            }
                          : null,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Loader(),
                            )
                          : const Text("Submit Form"),
                    ),
            ]));
  }
}
