import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/app/app.dart';
import 'package:safespine_bloc/settings/settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          _SettingsButton(),
          // IconButton(
          //   key: const Key('homePage_logout_iconButton'),
          //   icon: const Icon(Icons.exit_to_app),
          //   onPressed: () {
          //     context.read<AppBloc>().add(const AppLogoutRequested());
          //   },
          // )
        ],
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Avatar(photo: user.photo),
            // const SizedBox(height: 4),
            Text(user.email ?? '', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(user.name ?? '', style: textTheme.headlineSmall),
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
