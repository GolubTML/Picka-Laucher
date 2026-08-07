import "package:flutter/material.dart";
import "../models/mod_info.dart";

class ModCreatorDialog extends StatefulWidget {
  const ModCreatorDialog({super.key});

  @override
  State<ModCreatorDialog> createState() => _ModCreatorDialogState();
}

class _ModCreatorDialogState extends State<ModCreatorDialog> {
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override 
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Mod", style: TextStyle(fontFamily: "Terraria")),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Mod name",
            ),
          ),

          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: "Author name",
            ),
          ),

          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: "Description name",
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text("Cancle", style: TextStyle(fontFamily: "Terraria")),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              ModInfo(
                name: _nameController.text, 
                version: "1.0", 
                description: _descriptionController.text, 
                author: _authorController.text, 
                iconPath: "icon.png", 
                folderPath: ""
              )
            );
          }, 
          child: const Text("Create", style: TextStyle(fontFamily: "Terraria")),
        )
      ],
    );
  }
}