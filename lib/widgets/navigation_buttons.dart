import 'package:flutter/material.dart';


class NavigationButtons extends StatelessWidget {
  const NavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Home", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/mods");
              },
              child: const Text("Mods", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/patch");
              },
              child: const Text("Patch", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}