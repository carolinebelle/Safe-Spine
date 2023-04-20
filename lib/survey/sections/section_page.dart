import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safespine/services/models.dart';
import 'package:safespine/survey/sections/question_page.dart';
import 'package:safespine/survey/survey_state.dart';

class SectionPage extends StatefulWidget {
  final int sectionIndex;
  final Section section;
  const SectionPage(
      {super.key, required this.sectionIndex, required this.section});

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<SurveyState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.id),
        leading: widget.sectionIndex > 0
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
        actions: [
          widget.sectionIndex < state.format.sections.length
              ? Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      state.nextSection();
                    },
                    child: const Icon(
                      Icons.chevron_right,
                      size: 26.0,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: PageView.builder(
        // physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: state.questionController[widget.sectionIndex],
        itemCount: widget.section.questions.length,
        onPageChanged: (int idx) {
          // if (idx != state.questionIdx) {
        },
        itemBuilder: (BuildContext context, int idx) {
          return SafeArea(
            child: Column(children: [
              idx != 0
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.chevronUp,
                          color: Colors.grey),
                      tooltip: 'Go to previous question',
                      onPressed: () {
                        state.previousQuestion();
                      },
                    )
                  : Container(),
              Flexible(
                child: QuestionPage(
                  questionId: widget.section.questions[idx],
                  questionNum: idx,
                ),
              ),
              idx < widget.section.questions.length - 1
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.chevronDown,
                          color: Colors.grey),
                      tooltip: 'Go to next question',
                      onPressed: () {
                        state.nextQuestion();
                      },
                    )
                  : Container()
            ]),
          );
        },
      ),
    );
  }
}
