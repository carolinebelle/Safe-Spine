import 'package:flutter/material.dart';
import 'package:safespine/services/models.dart';
import 'package:safespine/survey/question_list.dart';

class SectionsDrawer extends StatelessWidget {
  final String title;
  final List<Section> sections;
  const SectionsDrawer({Key? key, required this.sections, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Drawer(
        child: Column(
          children: [
            Text(title),
            const Center(
              child: Icon(
                Icons.signal_wifi_connected_no_internet_4,
                size: 26.0,
              ),
            ),
          ],
        ),
      );
    } else {
      return Drawer(
        child: ListView.separated(
            shrinkWrap: true,
            itemCount: sections.length,
            itemBuilder: (BuildContext context, int idx) {
              Section section = sections[idx];
              if (idx == 0) {
                return Column(
                  children: [
                    // The header
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(title,
                          style: Theme.of(context).textTheme.headline4),
                    ),
                    // The fist list item
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          child: Text(
                            section.id,
                            // textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        QuestionList(section: section)
                      ],
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      section.id,
                      // textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  QuestionList(section: section)
                ],
              );
            },
            separatorBuilder: (BuildContext context, int idx) =>
                const Divider()),
      );
    }
  }
}
