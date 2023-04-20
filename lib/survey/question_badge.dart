import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuestionBadge extends StatelessWidget {
  final bool complete;

  const QuestionBadge({super.key, required this.complete});

  // bool checkStatus(BuildContext context, String id, List<String> completed) {
  //   Question? question = Provider.of<AppState>(context).questions[id];
  //   if (question == null) {
  //     return false;
  //   } else {
  //     if (question.type == "binary") {
  //       return completed.contains(questionId);
  //     } else {
  //       GroupQuestion groupQuestion = question as GroupQuestion;
  //       for (String subquestionId in groupQuestion.subquestions) {
  //         bool complete = checkStatus(context, subquestionId, completed);
  //         if (!complete) {
  //           return false;
  //         }
  //       }
  //       return true;
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // models.Form form = Provider.of<SurveyState>(context).form;
    // List<String> completed = form.answers.keys.toList();
    return complete
        ? const Icon(FontAwesomeIcons.checkDouble, color: Colors.green)
        : const Icon(FontAwesomeIcons.solidCircle, color: Colors.grey);
  }
}
