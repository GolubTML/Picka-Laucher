import "package:flutter/material.dart";
import 'package:external_app_launcher/external_app_launcher.dart';
import "../widgets/navigation_buttons.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(fontFamily: "Terraria"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "Main page", 
              style: TextStyle(fontFamily: "Terraria", fontSize: 28)
            ),

            const SizedBox(height: 80),

            ElevatedButton.icon(
              onPressed: () async {
                await LaunchApp.openApp(  
                  androidPackageName: 'com.and.games505.TerrariaPaid', 
                  openStore: true
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Launch Terraria", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
            )
          ]
        ),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}