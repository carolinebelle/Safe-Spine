import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/services/models.dart' as m;
import 'package:safespine/survey/question_badge.dart';
import 'package:safespine/survey/survey_state.dart';

class QuestionList extends StatelessWidget {
  final m.Section section;
  const QuestionList({Key? key, required this.section}) : super(key: key);

//TODO: query sqflite
  bool checkStatus(BuildContext context, String id, List<String> completed) {
    return false;
    // m.Question? question = Provider.of<AppState>(context).questions[id];
    // if (question == null) {
    //   return false;
    // } else {
    //   if (question.type == "binary") {
    //     return completed.contains(id);
    //   } else {
    //     m.GroupQuestion groupQuestion = question as m.GroupQuestion;
    //     for (String subquestionId in groupQuestion.subquestions) {
    //       bool complete = checkStatus(context, subquestionId, completed);
    //       if (!complete) {
    //         return false;
    //       }
    //     }
    //     return true;
    //   }
    // }
  }

  Widget getQuestionTile(BuildContext context, SurveyState state,
      String questionId, int sIdx, int qIdx) {
    m.Question? question = Provider.of<AppState>(context).questions[questionId];
    m.Form form = state.form;
    List<String> completed = form.answers.keys.toList();
    return question == null
        ? ListTile(
            title: Text(
              "Error",
              style: Theme.of(context).textTheme.headline5,
            ),
            subtitle: Text(
              "Unable to retrieve question info",
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            leading: QuestionBadge(
                complete: checkStatus(context, questionId, completed)),
          )
        : ListTile(
            title: Text(
              question.info,
              style: Theme.of(context).textTheme.headline5,
            ),
            leading: QuestionBadge(
                complete: checkStatus(context, questionId, completed)),
          );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<SurveyState>(context);
    var sectionNum = state.format.sections.indexOf(section.id);

    return Column(
      children: section.questions.map(
        (questionId) {
          return Card(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 4,
            margin: const EdgeInsets.all(4),
            child: Material(
              color: state.sectionIdx == sectionNum &&
                      state.questionIdx == section.questions.indexOf(questionId)
                  ? Colors.blue
                  : Colors.white,
              child: InkWell(
                onTap: () {
                  state.goToQuestion(sectionNum,
                      qIdx: section.questions.indexOf(questionId));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: getQuestionTile(context, state, questionId, sectionNum,
                      section.questions.indexOf(questionId)),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
