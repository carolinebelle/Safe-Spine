import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/services/models.dart' as models;

class AnimatedProgressbar extends StatelessWidget {
  final double value;
  final double height;

  const AnimatedProgressbar({super.key, required this.value, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return Container(
          padding: const EdgeInsets.all(10),
          width: box.maxWidth,
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(height),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: height,
                width: box.maxWidth * _floor(value),
                decoration: BoxDecoration(
                  color: _colorGen(value),
                  borderRadius: BorderRadius.all(
                    Radius.circular(height),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Always round negative or NaNs to min value
  _floor(double value, [min = 0.0]) {
    return value.sign <= min ? min : value;
  }

  _colorGen(double value) {
    int rbg = (value * 255).toInt();
    return Colors.deepOrange.withGreen(rbg).withRed(255 - rbg);
  }
}

class FormTypeProgress extends StatelessWidget {
  const FormTypeProgress({super.key, required this.format});

  final models.FormType format;

  @override
  Widget build(BuildContext context) {
    models.Form form = Provider.of<models.Form>(context);
    return Row(
      children: [
        _progressCount(format, form),
        Expanded(
          child: AnimatedProgressbar(
              value: _calculateProgress(format, form), height: 8),
        ),
      ],
    );
  }

  Widget _progressCount(models.FormType format, models.Form form) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        '${form.answers.length} / ${format.numQuestions}',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  double _calculateProgress(models.FormType format, models.Form form) {
    try {
      return form.answers.length / format.numQuestions;
    } catch (err) {
      return 0.0;
    }
  }
}
