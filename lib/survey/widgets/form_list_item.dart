import 'package:data_repository/data_repository.dart' as data_repo;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

import '../bloc/survey_bloc.dart';

class FormListItem extends StatelessWidget {
  final data_repo.Form form;
  const FormListItem({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    _deleteForm() async {
      data_repo.DataRepository dataRepository =
          context.read<data_repo.DataRepository>();
      dataRepository.deleteForm(form);
    }

    if (form.dateCompleted == null && form.dateStarted != null) {
      return ListTile(
          leading: const Icon(Icons.edit, color: Colors.red),
          title: Text(form.title),
          subtitle: Text(
              "Started: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateStarted!.millisecondsSinceEpoch))}"),
          onTap: () {
            context.read<SurveyBloc>().add(FormSelected(form));
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(form.title),
                  content: const Text("Would you like to delete this form?"),
                  actions: [
                    OutlinedButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        //proceed with delete
                        Navigator.of(context).pop();
                        _deleteForm();
                      },
                    )
                  ],
                );
              },
            );
          });
    } else if (form.dateReceived == null && form.dateCompleted != null) {
      return ListTile(
        leading: const Icon(Icons.signal_wifi_connected_no_internet_4,
            color: Colors.yellow),
        title: Text(form.title),
        subtitle: Text(
            "Completed: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateCompleted!.millisecondsSinceEpoch))}"),
        onTap: () {
          context.read<SurveyBloc>().add(FormSelected(form));
        },
      );
    } else if (form.dateReceived != null) {
      return ListTile(
        leading: const Icon(Icons.check, color: Colors.green),
        title: Text(form.title),
        subtitle: Text(
            "Received: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(form.dateReceived!.millisecondsSinceEpoch))}"),
        onTap: () {
          context.read<SurveyBloc>().add(FormSelected(form));
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.error, color: Colors.grey),
        title: Text(form.title),
      );
    }
  }
}
