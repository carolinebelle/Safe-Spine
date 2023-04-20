import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';

class AddHospital extends StatefulWidget {
  const AddHospital({super.key});

  @override
  State<AddHospital> createState() => _AddHospitalState();
}

class _AddHospitalState extends State<AddHospital> {
  TextEditingController nameController = TextEditingController();
  bool loading = false;
  String? successMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Hospital")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Hospital Name',
                ),
              ),
              const SizedBox(height: 15),
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
                            .addHospital(nameController.text);
                        setState(() {
                          successMessage =
                              "Success! Added ${nameController.text}";
                        });

                        nameController.clear();
                        loading = false;
                      },
                label: const Text("Add Hospital", textAlign: TextAlign.center),
              ),
              const SizedBox(height: 15),
              Text(successMessage ?? ""),
            ]),
      ),
    );
  }
}
