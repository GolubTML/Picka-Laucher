import "package:flutter/material.dart";
import "../widgets/navigation_buttons.dart";
import "../widgets/mod_card.dart";
import "../models/mod_info.dart";
import "../services/mods_loader.dart";

class ModsPage extends StatefulWidget {
  const ModsPage({super.key});

  @override
  State<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends State<ModsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mods"),
      ),
      body: FutureBuilder<List<ModInfo>>(
        future: loadMods(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final mods = snapshot.data ?? [];

          if (mods.isEmpty) {
            return const Center(child: Text("There is no mods yet.. :("));
          }

          return ListView.builder(
            itemCount: mods.length,
            itemBuilder: (context, index) {
              return ModCard(mod: mods[index]);
            },
          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: "Create basic mod",
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}