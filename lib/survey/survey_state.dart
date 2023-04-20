import 'package:flutter/material.dart';
import 'package:safespine/services/models.dart' as m;

class SurveyState with ChangeNotifier {
  final PageController sectionController = PageController();
  final List<PageController> questionController;
  final m.Form _form;
  final m.FormType _format;
  // List<Map<String, int>> _questionCounts;

  int? _sectionIdx = 0;
  int? _questionIdx = 0;

  SurveyState({required m.Form form, required m.FormType format})
      : _form = form,
        _format = format,
        // _questionCounts = questionCounts,
        questionController =
            List.filled(format.sections.length, PageController());

  m.Form get form => _form;

  m.FormType get format => _format;

  int? get sectionIdx => _sectionIdx;

  int? get questionIdx => _questionIdx;

  set sectionIdx(int? newValue) {
    _sectionIdx = newValue;
    notifyListeners();
  }

  set questionIdx(int? newValue) {
    _questionIdx = newValue;
    notifyListeners();
  }

  void setAnswer(String id, String ans) {
    if (sectionIdx != null) {
      // _questionCounts[sectionIdx!]["answers"] =
      // _questionCounts[sectionIdx!]["answers"]! + 1;
      _form.answers[id] = ans;
      notifyListeners();
    }
  }

  void clearAnswer(String id) {
    if (sectionIdx != null) {
      // _questionCounts[sectionIdx!]["answers"] =
      //     _questionCounts[sectionIdx!]["answers"]! - 1;
      _form.answers.remove(id);
      notifyListeners();
    }
  }

  bool hasAnswer(String id) {
    return _form.answers.containsKey(id);
  }

  String? getAnswer(String id) {
    return _form.answers[id];
  }

  // double progress(int sectionIndex) =>
  //     (_questionCounts[sectionIndex]["answers"] ?? 0) /
  //     (_questionCounts[sectionIndex]["total"] ?? 1);

  void nextSection() async {
    if (sectionIdx != null) {
      if (sectionIdx! + 1 < _format.sections.length + 1) {
        sectionIdx = sectionIdx! + 1;
        questionIdx = 0;
        await sectionController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void previousSection() async {
    if (sectionIdx != null) {
      if (sectionIdx! - 1 >= 0) {
        sectionIdx = sectionIdx! - 1;
        questionIdx = 0;
        await sectionController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void nextQuestion() async {
    if (questionIdx != null && sectionIdx != null) {
      questionIdx = questionIdx! + 1;
      await questionController[sectionIdx!].nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void previousQuestion() async {
    if (questionIdx != null && sectionIdx != null) {
      questionIdx = questionIdx! - 1;
      await questionController[sectionIdx!].previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> goToQuestion(int sIdx, {int qIdx = 0}) async {
    print("calling go to section $sIdx and question $qIdx");
    if (sIdx >= 0 && sIdx < _format.sections.length) {
      questionIdx = null;
      print("go to section $sIdx");
      await sectionController.animateToPage(sIdx,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
      sectionIdx = sIdx;
      print("go to question $qIdx");
      await questionController[sIdx].animateToPage(qIdx,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
      questionIdx = qIdx;
    }
    print("---------------------------------------");
  }
}
