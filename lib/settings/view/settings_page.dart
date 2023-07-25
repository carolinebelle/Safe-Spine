import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safespine_bloc/settings/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(context.read<AuthenticationRepository>()),
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.success) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Success'),
                content: Text(state.message ?? ''),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state.status == SettingsStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message ?? 'Error')),
              );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [_LogOutButton()],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_ResetPasswordButton(), _DeleteAccountButton()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('settings_resetPassword_flatButton'),
      onPressed: () => context.read<SettingsCubit>().passwordResetRequested(),
      child: const Text('RESET PASSWORD'),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      key: const Key('settings_deleteAccount_flatButton'),
      onPressed: () => context.read<SettingsCubit>().deleteUserRequested(),
      child: Text(
        'DELETE ACCOUNT',
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('settings_logOut_elevatedButton'),
      onPressed: () => context.read<SettingsCubit>().signOutRequested(),
      icon: const Icon(Icons.logout),
    );
  }
}
