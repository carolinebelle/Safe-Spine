import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/services/models.dart';
import 'package:safespine/survey/survey_state.dart';

class QuestionPage extends StatelessWidget {
  final int questionNum;
  final String questionId;
  const QuestionPage(
      {super.key, required this.questionId, required this.questionNum});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(children: [
        QuestionItem(questionId: questionId, num: questionNum, depth: 0)
      ]),
    );
  }
}

class BinaryQuestionItem extends StatelessWidget {
  final BinaryQuestion question;
  final int num;
  final int depth;
  const BinaryQuestionItem(
      {super.key,
      required this.question,
      required this.num,
      required this.depth});

  @override
  Widget build(BuildContext context) {
    const List<int> arabianRomanNumbers = [
      1000,
      900,
      500,
      400,
      100,
      90,
      50,
      40,
      10,
      9,
      5,
      4,
      1
    ];

    const List<String> romanNumbers = [
      "m",
      "cm",
      "d",
      "cd",
      "c",
      "xc",
      "l",
      "xl",
      "x",
      "ix",
      "v",
      "iv",
      "i"
    ];

    String intToRoman(int input) {
      var num = input;

      if (num < 0) {
        return "";
      } else if (num == 0) {
        return "nulla";
      }

      final builder = StringBuffer();
      for (var a = 0; a < arabianRomanNumbers.length; a++) {
        final times = (num / arabianRomanNumbers[a])
            .truncate(); // equals 1 only when arabianRomanNumbers[a] = num
        // executes n times where n is the number of times you have to add
        // the current roman number value to reach current num.
        builder.write(romanNumbers[a] * times);
        num -= times *
            arabianRomanNumbers[
                a]; // subtract previous roman number value from num
      }

      return builder.toString();
    }

    String getLeadingText() {
      if (depth == 0) {
        return "${num + 1}. ";
      } else if (depth == 1) {
        List<String> alphabet = [
          "A",
          "B",
          "C",
          "D",
          "E",
          "F",
          "G",
          "H",
          "I",
          "J",
          "K",
          "L",
          "M",
          "N",
          "O",
          "P",
          "Q",
          "R",
          "S",
          "T",
          "U",
          "V",
          "W",
          "X",
          "Y",
          "Z"
        ];
        return "${alphabet[num]}. ";
      } else if (depth == 2) {
        return "${intToRoman(num + 1)}. ";
      } else {
        return "• ";
      }
    }

    TextStyle? getStyle() {
      if (depth == 0) {
        return Theme.of(context).textTheme.headline5;
      } else if (depth == 1) {
        return Theme.of(context).textTheme.headline6;
      } else if (depth == 2) {
        return Theme.of(context).textTheme.bodyText1;
      } else {
        return Theme.of(context).textTheme.bodyText2;
      }
    }

    SurveyState state = Provider.of<SurveyState>(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(
            child:
                Text("${getLeadingText()} ${question.info}", style: getStyle()))
      ]),
      RadioListTile(
        title: const Text("Yes"),
        value: "yes",
        groupValue: state.getAnswer(question.id),
        onChanged: (value) {
          if (value == null) {
            state.clearAnswer(question.id);
          } else {
            state.setAnswer(question.id, value);
          }
        },
      ),
      RadioListTile(
        title: const Text("No"),
        value: "no",
        groupValue: state.getAnswer(question.id),
        onChanged: (value) {
          if (value == null) {
            state.clearAnswer(question.id);
          } else {
            state.setAnswer(question.id, value);
          }
        },
      )
    ]);
  }
}

class QuestionItem extends StatelessWidget {
  final String questionId;
  final int num;
  final int depth;
  const QuestionItem(
      {super.key,
      required this.questionId,
      required this.num,
      required this.depth});

  @override
  Widget build(BuildContext context) {
    Future<Question> questionSnapshot =
        Provider.of<AppState>(context).service.getQuestion(questionId);
    return FutureBuilder(
        future: questionSnapshot,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Question question = snapshot.data!;
            if (question.type == "binary") {
              return BinaryQuestionItem(
                  question: question as BinaryQuestion, num: num, depth: depth);
            } else {
              return GroupQuestionItem(
                  question: question as GroupQuestion, num: num, depth: depth);
            }
          } else {
            return const Text("Unable to retrieve question.");
          }
        });
  }
}

class GroupQuestionItem extends StatelessWidget {
  final GroupQuestion question;
  final int num;
  final int depth;
  const GroupQuestionItem(
      {super.key,
      required this.question,
      required this.num,
      required this.depth});

  @override
  Widget build(BuildContext context) {
    final List fixedList =
        Iterable<int>.generate(question.subquestions.length).toList();

    const List<int> arabianRomanNumbers = [
      1000,
      900,
      500,
      400,
      100,
      90,
      50,
      40,
      10,
      9,
      5,
      4,
      1
    ];

    const List<String> romanNumbers = [
      "m",
      "cm",
      "d",
      "cd",
      "c",
      "xc",
      "l",
      "xl",
      "x",
      "ix",
      "v",
      "iv",
      "i"
    ];

    String intToRoman(int input) {
      var num = input;

      if (num < 0) {
        return "";
      } else if (num == 0) {
        return "nulla";
      }

      final builder = StringBuffer();
      for (var a = 0; a < arabianRomanNumbers.length; a++) {
        final times = (num / arabianRomanNumbers[a])
            .truncate(); // equals 1 only when arabianRomanNumbers[a] = num
        // executes n times where n is the number of times you have to add
        // the current roman number value to reach current num.
        builder.write(romanNumbers[a] * times);
        num -= times *
            arabianRomanNumbers[
                a]; // subtract previous roman number value from num
      }

      return builder.toString();
    }

    String getLeadingText() {
      if (depth == 0) {
        return "${num + 1}. ";
      } else if (depth == 1) {
        List<String> alphabet = [
          "A",
          "B",
          "C",
          "D",
          "E",
          "F",
          "G",
          "H",
          "I",
          "J",
          "K",
          "L",
          "M",
          "N",
          "O",
          "P",
          "Q",
          "R",
          "S",
          "T",
          "U",
          "V",
          "W",
          "X",
          "Y",
          "Z"
        ];
        return "${alphabet[num]}. ";
      } else if (depth == 2) {
        return "${intToRoman(num + 1)}. ";
      } else {
        return "• ";
      }
    }

    TextStyle? getStyle() {
      if (depth == 0) {
        return Theme.of(context).textTheme.headline5;
      } else if (depth == 1) {
        return Theme.of(context).textTheme.headline6;
      } else if (depth == 2) {
        return Theme.of(context).textTheme.bodyText1;
      } else {
        return Theme.of(context).textTheme.bodyText2;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${getLeadingText()} ${question.info}", style: getStyle()),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              for (var index in fixedList)
                QuestionItem(
                    questionId: question.subquestions[index],
                    num: index,
                    depth: depth + 1),
            ],
          ),
        ),
      ],
    );
  }
}
