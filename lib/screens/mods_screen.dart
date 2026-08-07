import "package:flutter/material.dart";
import "../widgets/navigation_buttons.dart";
import "../widgets/mod_card.dart";
import "../models/mod_info.dart";
import "../services/mods_loader.dart";
import '../widgets/mod_creator_dialog.dart';
import '../services/mod_creation.dart';

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
        title: Text("Mods", style: TextStyle(fontFamily: "Terraria")),
      ),
      body: FutureBuilder<List<ModInfo>>(
        future: loadMods(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontFamily: "Terraria")));
          }

          final mods = snapshot.data ?? [];

          if (mods.isEmpty) {
            return const Center(child: Text("There is no mods yet.. :(", style: TextStyle(fontFamily: "Terraria")));
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
        onPressed: () async {
          final mod = await showDialog<ModInfo>(
            context: context,
            builder: (_) => const ModCreatorDialog(),
          );

          if (!mounted) return;

          if (mod == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cannot create mod :(", style: TextStyle(fontFamily: "Terraria"))),
            );
            return;
          }

          try {
            await createMod(mod);

            if (!mounted) return;

            setState(() {});

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Mod created successfully!", style: TextStyle(fontFamily: "Terraria")),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: $e", style: TextStyle(fontFamily: "Terraria")),
              ),
            );
          }
        },
        tooltip: "Create basic mod",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}