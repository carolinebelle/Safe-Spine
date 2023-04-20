import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';

import '../services/models.dart';

class ModifyQuestions extends StatefulWidget {
  const ModifyQuestions({super.key});

  @override
  State<ModifyQuestions> createState() => _ModifyQuestionsState();
}

class _ModifyQuestionsState extends State<ModifyQuestions> {
  @override
  Widget build(BuildContext context) {
    Map<String, Question> questions = Provider.of<AppState>(context).questions;

    return Scaffold(
        appBar: AppBar(title: const Text("Modify Questions")),
        body: SingleChildScrollView(
            child: Column(
                children: questions.entries
                    .map((entry) =>
                        EditQuestion(id: entry.key, question: entry.value))
                    .toList())));
  }
}

class EditQuestion extends StatefulWidget {
  const EditQuestion({super.key, required this.id, required this.question});
  final String id;
  final Question question;

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  TextEditingController infoController = TextEditingController();
  bool loading = false;
  String? successMessage;

  @override
  Widget build(BuildContext context) {
    infoController.text = widget.question.info;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: infoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Question Info',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.blue,
              ),
              onPressed: loading
                  ? null
                  : () async {
                      print("saving question modification");
                      loading = true;
                      await Provider.of<AppState>(context, listen: false)
                          .modifyQuestion(widget.id, infoController.text);
                      setState(() {
                        successMessage =
                            "Success! Updated ${widget.id} ${infoController.text}";
                      });
                      loading = false;
                    },
              label: const Text("Update Question", textAlign: TextAlign.center),
            ),
            const SizedBox(height: 15),
            Text(successMessage ?? ""),
          ]),
    );
  }
}
