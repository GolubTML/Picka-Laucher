import "package:flutter/material.dart";
import "../widgets/navigation_buttons.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: const Center(
        child: Text(
          "Main page", 
          style: TextStyle(fontSize: 24)
        ),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}