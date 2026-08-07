import "dart:io";
import "package:flutter/material.dart";
import "../models/mod_info.dart";
import "../services/mod_delete.dart";

class ModPage extends StatelessWidget {
  final ModInfo mod;

  const ModPage({super.key, required this.mod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mod view", style: TextStyle(fontFamily: "Terraria")),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Image.file(
                  File(mod.iconPath),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                )
              ),

              const Divider(height: 32),

              Text(mod.name, style: TextStyle(fontFamily: "Terraria")),

              ListTile(
                leading: Icon(Icons.tag),
                title: Text("Version", style: TextStyle(fontFamily: "Terraria")),
                subtitle: Text(mod.version, style: TextStyle(fontFamily: "Terraria")),
              ),

              ListTile(
                title: Text("Author", style: TextStyle(fontFamily: "Terraria")),
                subtitle: Text(mod.author, style: TextStyle(fontFamily: "Terraria")),
              ),

              const Divider(height: 32),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Text(mod.description, style: TextStyle(fontFamily: "Terraria")),
                ),
              )
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
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
                  Navigator.pop(context);
                },
                child: const Text("Back", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context, 
                    builder: (_) => AlertDialog(
                      title: const Text("Delete mod?", style: TextStyle(fontFamily: "Terraria")),
                      content: Text("Delete ${mod.name}?", style: TextStyle(fontFamily: "Terraria")),

                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel", style: TextStyle(fontFamily: "Terraria"))
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete", style: TextStyle(fontFamily: "Terraria"))
                        ),
                      ],
                    )
                  );

                  if (result == true) {
                    await deleteMod(mod.folderPath);

                    if (!context.mounted) return;

                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Delete", style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
              ),
            ],
          ),
        ) 
      ),
    );
  }
}