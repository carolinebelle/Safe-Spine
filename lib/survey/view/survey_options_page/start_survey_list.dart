import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_repository/data_repository.dart' as data_repo;

import '../../survey.dart';

class StartSurveyScreen extends StatelessWidget {
  const StartSurveyScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const StartSurveyScreen());
  }

  @override
  Widget build(BuildContext context) {
    final SurveyState state = context.watch<SurveyBloc>().state;
    List<data_repo.Hospital> hospitals = state.hospitals;
    data_repo.Survey survey = state.survey;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Hospital"),
      ),
      body: SelectHospital(survey: survey, hospitals: hospitals),
    );
  }
}

class SelectHospital extends StatefulWidget {
  final List<data_repo.Hospital> hospitals;
  final data_repo.Survey survey;
  const SelectHospital(
      {super.key, required this.hospitals, required this.survey});

  @override
  State<SelectHospital> createState() => _SelectHospitalState();
}

class _SelectHospitalState extends State<SelectHospital> {
  data_repo.Hospital? hospital;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select hospital: "),
        Center(
          child: DropdownButton(
            value: hospital,
            items: widget.hospitals
                .map((data_repo.Hospital h) => DropdownMenuItem(
                      value: h,
                      child: Text(h.name),
                    ))
                .toList(),
            onChanged: (data_repo.Hospital? newValue) {
              setState(() {
                hospital = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: hospital != null
              ? () {
                  // When the user taps the button,
                  // navigate to a named route and
                  // provide the arguments as an optional
                  // parameter.

                  context.read<SurveyBloc>().add(HospitalSelected(hospital!));
                }
              : null,
          child: const Text('Start Survey'),
        ),
      ],
    );
  }
}
