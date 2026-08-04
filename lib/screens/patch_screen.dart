import "package:flutter/material.dart";
import "../widgets/navigation_buttons.dart";

class PatchScreen extends StatelessWidget {
  const PatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patch"),
      ),
      body: const Center(
        child: Text(
          "Here game will be patched", 
          style: TextStyle(fontSize: 24)
        ),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}