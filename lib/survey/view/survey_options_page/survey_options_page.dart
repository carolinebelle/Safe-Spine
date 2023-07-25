import 'package:authentication_repository/authentication_repository.dart';
import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/admin/admin.dart';

import '../../../settings/view/view.dart';

class SurveyOptionsPage extends StatelessWidget {
  const SurveyOptionsPage({Key? key}) : super(key: key);

  static Page<void> page() =>
      const MaterialPage<void>(child: SurveyOptionsPage());

  @override
  Widget build(BuildContext context) {
    DataRepository dataRepository = context.read<DataRepository>();
    AuthenticationRepository authenticationRepository =
        context.read<AuthenticationRepository>();

    Future<bool> _isAdmin =
        dataRepository.isAdmin(authenticationRepository.currentUser.id ?? "");

    return Scaffold(
        appBar: AppBar(
          title: const Text('Survey Options'),
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
