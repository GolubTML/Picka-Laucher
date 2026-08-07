import "package:flutter/material.dart";
import "dart:io";

import "../models/mod_info.dart";

class ModCard extends StatelessWidget {
  final ModInfo mod;
  final VoidCallback? onTap;

  const ModCard({super.key, required this.mod, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      leading: Container(
        width: 48,
        height: 48,
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
       
      title: Text(mod.name, style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
      
      subtitle: Text(
        "${mod.author}\n${mod.description}",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: "Terraria", fontSize: 18)
      ),

      trailing: Text(mod.version, style: TextStyle(fontFamily: "Terraria", fontSize: 18)),
    );
  }
}