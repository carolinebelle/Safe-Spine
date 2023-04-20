import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';

class CSV extends StatefulWidget {
  const CSV({super.key});

  @override
  State<CSV> createState() => _CSVState();
}

class _CSVState extends State<CSV> {
  bool loading = false;
  String? successMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download CSV")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.blue,
                ),
                onPressed: loading
                    ? null
                    : () async {
                        loading = true;
                        await Provider.of<AppState>(context, listen: false)
                            .csv();
                        setState(() {
                          successMessage = "Success! Generated CSV";
                        });
                        loading = false;
                      },
                label: const Text("Download CSV", textAlign: TextAlign.center),
              ),
              const SizedBox(height: 15),
              Text(successMessage ?? ""),
            ]),
      ),
    );
  }
}
