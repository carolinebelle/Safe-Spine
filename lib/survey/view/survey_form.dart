import 'package:flutter/material.dart';

/**
 * Edit answers of form
 * Routes
 * - sections
 * - overview
 */

class SurveyForm extends StatelessWidget {
  const SurveyForm({Key? key}) : super(key: key);

  static Page<void> page() => const MaterialPage<void>(child: SurveyForm());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Survey Form'),
        ),
        body: const Column(
          children: [Text("Survey Form")],
        ));
  }
}
