import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/history/form_item.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/firestore.dart';
import 'package:safespine/services/models.dart' as m;
import 'package:safespine/shared/loading.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    final appState = Provider.of<AppState>(context);
    final FirestoreService service = appState.service;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  signOut(context, () {
                    if (!mounted) {
                      return;
                    }
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  });
                },
                child: const Icon(
                  Icons.logout,
                  size: 26.0,
                ),
              ))
        ],
      ),
      body: StreamBuilder<List<m.Form>>(
          stream: service.streamForms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No user forms, yet."));
              } else {
                return SafeArea(
                  child: ListView(
                    children: snapshot.data!
                        .map((form) => FormItem(form: form))
                        .toList(),
                  ),
                );
              }
            } else {
              return const Center(
                child:
                    Text("An issue occured while retrieving your form history"),
              );
            }
          }),
    );
  }

  Future<void> signOut(BuildContext context, VoidCallback onSuccess) async {
    await AuthService().signOut();
    onSuccess.call();
  }
}
