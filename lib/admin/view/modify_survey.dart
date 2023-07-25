import 'package:flutter/material.dart';

class ModifySurvey extends StatelessWidget {
  const ModifySurvey({Key? key}) : super(key: key);

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ModifySurvey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModifySurvey'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("ModifySurvey")],
        ),
      ),
    );
  }
}
