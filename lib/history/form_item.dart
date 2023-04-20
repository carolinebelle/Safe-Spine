import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/services/models.dart' as m;
// VSCode linting error. Dependency used for DateFormat.
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:safespine/survey/survey.dart';

class FormItem extends StatelessWidget {
  final m.Form form;
  const FormItem({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    if (form.dateCompleted == null && form.dateStarted != null) {
      return ListTile(
        leading: const Icon(Icons.edit, color: Colors.red),
        title: Text(form.title),
        subtitle: Text(
            "Started: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateStarted!.millisecondsSinceEpoch))}"),
        onTap: () {
          var formats = Provider.of<AppState>(context, listen: false).formats;
          var format = formats[
              formats.indexWhere((element) => element.id == form.form_type)];
          var hospitals =
              Provider.of<AppState>(context, listen: false).hospitals;
          var hospital = hospitals[
              hospitals.indexWhere((element) => element.id == form.hospital)];
          Navigator.pushNamed(
            context,
            '/survey',
            arguments: SurveyScreenArguments(format, hospital, form: form),
          );
        },
      );
    } else if (form.dateReceived == null && form.dateCompleted != null) {
      return ListTile(
        leading: const Icon(Icons.signal_wifi_connected_no_internet_4,
            color: Colors.yellow),
        title: Text(form.title),
        subtitle: Text(
            "Completed: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateCompleted!.millisecondsSinceEpoch))}"),
      );
    } else if (form.dateReceived != null) {
      return ListTile(
        leading: const Icon(Icons.check, color: Colors.green),
        title: Text(form.title),
        subtitle: Text(
            "Received: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateReceived!.millisecondsSinceEpoch))}"),
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.error, color: Colors.grey),
        title: Text(form.title),
      );
    }
  }
}
