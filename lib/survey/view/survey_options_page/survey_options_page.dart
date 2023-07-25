import 'package:authentication_repository/authentication_repository.dart';
import 'package:data_repository/data_repository.dart' as data_repo;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/admin/admin.dart';
import 'package:safespine_bloc/survey/survey.dart';
import '../../../settings/view/view.dart';
import 'view.dart';

class SurveyOptionsPage extends StatelessWidget {
  const SurveyOptionsPage({Key? key}) : super(key: key);

  static Page<void> page() =>
      const MaterialPage<void>(child: SurveyOptionsPage());

  @override
  Widget build(BuildContext context) {
    data_repo.DataRepository dataRepository =
        context.read<data_repo.DataRepository>();
    AuthenticationRepository authenticationRepository =
        context.read<AuthenticationRepository>();

    Future<bool> _isAdmin =
        dataRepository.isAdmin(authenticationRepository.currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orthopaedic Link'),
        leading: FutureBuilder<bool>(
            future: _isAdmin,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  return _AdminButton();
                }
              }
              return Container();
            }),
        actions: [_SettingsButton()],
      ),
      body: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            NewSurveyOptionsList(),
            Divider(),
            Expanded(child: HistoryList())
          ],
        ),
      ),
    );
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

class _AdminButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('homePage_admin_iconButton'),
      icon: const Icon(Icons.admin_panel_settings),
      onPressed: () => Navigator.of(context).push<void>(AdminMenu.route()),
    );
  }
}
