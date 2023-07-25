import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/**
 * choose hospital from list to start new form
 */

// static Route<void> route() {
//     return MaterialPageRoute<void>(builder: (_) => const SignUpPage());
//   }

class HospitalSelectPage extends StatelessWidget {
  const HospitalSelectPage({Key? key}) : super(key: key);

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const HospitalSelectPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Hospital Select'),
        ),
        body: const Column(
          children: [Text("Hospital List")],
        ));
  }
}
