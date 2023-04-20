import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.plus,
              size: 20,
            ),
            label: 'Forms',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.clockRotateLeft,
              size: 20,
            ),
            label: 'History',
          ),
        ],
        onTap: (int idx) {
          switch (idx) {
            case 0:
              // do nothing
              break;
            case 1:
              Navigator.pushNamed(context, '/history');
              break;
          }
        });
  }
}
