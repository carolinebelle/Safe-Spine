import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/routes.dart';
import 'package:safespine/services/connectivity.dart';
import 'package:safespine/services/lifecycle.dart';
import 'package:safespine/shared/loading.dart';
import 'package:safespine/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Text("Error", textDirection: TextDirection.ltr);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamProvider<bool>(
            create: (_) => ConnectivityService().checkConnectivity(),
            initialData: false,
            child: const WrappedApp(),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(
          child: Loader(),
        );
      },
    );
  }
}

class WrappedApp extends StatefulWidget {
  const WrappedApp({super.key});

  @override
  State<WrappedApp> createState() => _WrappedAppState();
}

class _WrappedAppState extends State<WrappedApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              if (mounted) {
                print("main.dart ---------- resumeCallback");
                _state.refreshFromFirebase();
              }
            })));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _state,
      child: MaterialApp(
          debugShowCheckedModeBanner: true, theme: appTheme, routes: appRoutes),
    );
  }
}
