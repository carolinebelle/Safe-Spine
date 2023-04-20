import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/services/models.dart' as models;
import 'package:safespine/services/models.dart';
import 'package:safespine/survey/drawer.dart';
import 'package:safespine/survey/sections/complete_page.dart';
import 'package:uuid/uuid.dart';

// VSCode linting error. Dependency used for DateFormat.
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:safespine/survey/sections/section_page.dart';
import 'package:safespine/survey/survey_state.dart';

class SurveyScreenArguments {
  final models.FormType format;
  final models.Form? form;
  final Hospital hospital;

  SurveyScreenArguments(this.format, this.hospital, {this.form});
}

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    final args =
        ModalRoute.of(context)!.settings.arguments as SurveyScreenArguments;

    final format = args.format;
    final hospital = args.hospital;

    final title =
        "${hospital.name}: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";

    Map<String, Section> sections = Provider.of<AppState>(context).sections;

    List<Section> sectionsList = format.sections
        .map((sectionId) => sections[sectionId] ?? Section(id: sectionId))
        .toList();

    final models.Form form = args.form ??
        models.Form(
            id: const Uuid().v4(),
            dateStarted: Timestamp.now(),
            form_type: format.id,
            hospital: hospital.id,
            title: title,
            user: AuthService().user?.uid ?? "no user");

    // Map<String, int> countSubquestions(Question question) {
    //   if (question.type == "binary") {
    //     if (form.answers.containsKey(question.id)) {
    //       return {"total": 1, "answers": 1};
    //     } else {
    //       return {"total": 1, "answers": 0};
    //     }
    //   } else {
    //     GroupQuestion groupQuestion = question as GroupQuestion;
    //     int total = 0;
    //     int answers = 0;
    //     for (var subquestionId in groupQuestion.subquestions) {
    //       Question? nextQuestion =
    //           Provider.of<AppState>(context).questions[subquestionId];
    //       if (nextQuestion != null) {
    //         var map = countSubquestions(nextQuestion);
    //         total += map["total"] ?? 0;
    //         answers += map["answers"] ?? 0;
    //       }
    //     }
    //     return {"total": total, "answers": answers};
    //   }
    // }

    // List<Map<String, int>> sectionQuestionCounts() {
    //   List<Map<String, int>> counts = [];
    //   int sectionNum = 0;
    //   while (sectionNum < sections.length) {
    //     int total = 0;
    //     int answers = 0;
    //     Section? section = sections[format.sections[sectionNum]];
    //     if (section != null) {
    //       for (var questionId in section.questions) {
    //         Question? question =
    //             Provider.of<AppState>(context).questions[questionId];
    //         if (question != null) {
    //           var map = countSubquestions(question);
    //           total += map["total"] ?? 0;
    //           answers += map["answers"] ?? 0;
    //         }
    //       }
    //     }
    //     counts.add({"total": total, "answers": answers});
    //   }
    //   return counts;
    // }

    SurveyState state = SurveyState(form: form, format: format);

    return WillPopScope(
      onWillPop: () async => !Navigator.of(context).userGestureInProgress,
      child: ChangeNotifierProvider<SurveyState>.value(
        value: state,
        child: Scaffold(
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            backgroundColor: Colors.deepPurple,
            title: Text(title),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      FirestoreService().updateForm(state.form);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Icon(FontAwesomeIcons.xmark),
                  )),
            ],
          ),
          body: PageView.builder(
              // physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: state.sectionController,
              itemCount: state.format.sections.length + 1,
              onPageChanged: (int idx) {},
              itemBuilder: (BuildContext context, int idx) {
                if (idx == state.format.sections.length) {
                  return CompletePage(sectionIndex: idx);
                } else {
                  Section? section = Provider.of<AppState>(context)
                      .sections[state.format.sections[idx]];
                  if (section != null) {
                    return SectionPage(
                        key: ValueKey(idx),
                        sectionIndex: idx,
                        section: section);
                  } else {
                    return const Center(
                        child: Text("Error retrieving section."));
                  }
                }
              }),
          drawer: SectionsDrawer(
            title: title,
            sections: sectionsList,
          ),
        ),
      ),
    );
  }
}
