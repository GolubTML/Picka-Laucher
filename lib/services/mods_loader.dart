import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart";

import "../models/mod_info.dart";

Future<List<ModInfo>> loadMods() async {
  final mods = <ModInfo>[];

  final modsDirectory = Directory("/storage/emulated/0/Mods/");

  if (!await modsDirectory.exists()) {
    await modsDirectory.create(recursive: true);
  }

  await for (final entity in modsDirectory.list()) {
    if (entity is! Directory) continue;

    try {
      final configFile = File("${entity.path}/config.json");

      if (!await configFile.exists()) {
        continue;
      }

      final json = jsonDecode(await configFile.readAsString());

      mods.add(
        ModInfo.fromJson(
          json,
          folderPath: entity.path,
        ),
      );
    } catch (e) {
      debugPrint("Skipping ${entity.path}: $e");
    }
  }

  return mods;
}