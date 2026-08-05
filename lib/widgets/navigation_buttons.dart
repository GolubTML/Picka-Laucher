import 'package:flutter/material.dart';


class NavigationButtons extends StatelessWidget {
  const NavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,

      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('Home'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/mods');
          },
          child: const Text('Mods'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/patch');
          },
          child: const Text('Patch'),
        ),
      ]
    );
  }
}