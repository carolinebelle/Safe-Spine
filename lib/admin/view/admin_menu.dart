import 'package:flutter/material.dart';

class AdminMenu extends StatelessWidget {
  const AdminMenu({Key? key}) : super(key: key);

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AdminMenu());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_EditHospitals(), _EditSurvey(), _EditWhitelist()],
        ),
      ),
    );
  }
}

class _EditSurvey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('adminMenu_editSurvey_iconButton'),
      onPressed: () => {},
      child: const Text('Edit Survey'),
    );
  }
}

class _EditHospitals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('adminMenu_editHospitals_iconButton'),
      onPressed: () => {},
      child: const Text('Add Hospital'),
    );
  }
}

class _EditWhitelist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('adminMenu_editWhitelist_iconButton'),
      onPressed: () => {},
      child: const Text('Add to Whitelist'),
    );
  }
}
