import 'package:flutter/material.dart';
import 'package:safespine/services/models.dart';

import 'form_type_screen.dart';

class FormTypeItem extends StatelessWidget {
  final FormType form;
  const FormTypeItem({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: form.id,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => FormTypeScreen(form: form),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                size: 26.0,
                color: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  form.title,
                  style: const TextStyle(
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
