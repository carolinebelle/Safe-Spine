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

    SurveyState state = SurveyState(form: form, format: format);

    final appState = Provider.of<AppState>(context);
    final FirestoreService service = appState.service;

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
                      service.updateForm(state.form);
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
