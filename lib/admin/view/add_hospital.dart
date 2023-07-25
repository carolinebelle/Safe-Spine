import 'package:flutter/material.dart';

class AddHospital extends StatelessWidget {
  const AddHospital({Key? key}) : super(key: key);

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AddHospital());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hospital'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Add Hospital")],
        ),
      ),
    );
  }
}
