import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuestionBadge extends StatelessWidget {
  final bool complete;

  const QuestionBadge({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    return complete
        ? const Icon(FontAwesomeIcons.checkDouble, color: Colors.green)
        : const Icon(FontAwesomeIcons.solidCircle, color: Colors.grey);
  }
}
