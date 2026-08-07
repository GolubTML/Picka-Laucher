import "package:flutter/material.dart";
import "dart:io";

import "../models/mod_info.dart";

class ModCard extends StatelessWidget {
  final ModInfo mod;

  const ModCard({super.key, required this.mod});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.file(
        File(mod.iconPath),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
      ),
       
      title: Text(mod.name),
      
      subtitle: Text(
        "${mod.author}\n${mod.description}",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: Text(mod.version),
    );
  }
}