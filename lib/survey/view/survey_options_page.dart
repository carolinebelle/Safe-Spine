import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../settings/view/view.dart';

/**
 * List of Survey Types
 *  - select hospital 
 *      () => Navigator.of(context).push<void>(HospitalSelectPage.route()),
 * List of User's Forms (History)
 */

class SurveyOptionsPage extends StatelessWidget {
  const SurveyOptionsPage({Key? key}) : super(key: key);

  static Page<void> page() =>
      const MaterialPage<void>(child: SurveyOptionsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Survey Options'),
          actions: [_SettingsButton()],
        ),
        body: const Column(
          children: [Text("Survey Types List"), Divider(), Text("History")],
        ));
  }
}

class _SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('homePage_settings_iconButton'),
      icon: const Icon(Icons.settings),
      onPressed: () => Navigator.of(context).push<void>(SettingsPage.route()),
    );
  }
}
