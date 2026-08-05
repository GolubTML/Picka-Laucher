import "dart:io";
import "dart:convert";
import "package:flutter/services.dart";
import '../models/mod_info.dart';

Future<void> createMod(ModInfo mod) async {
  final folderName = mod.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), "_");

  final dir = Directory("/storage/emulated/0/Mods/$folderName");

  await dir.create(recursive: true);

  final config = {
    "name": mod.name,
    "version": mod.version,
    "description": mod.description,
    "author": mod.author
  };

  await File("${dir.path}/config.json")
      .writeAsString(jsonEncode(config));

  await File("${dir.path}/main.lua")
      .writeAsBytes(
          (await rootBundle.load("assets/default_mod/main.lua"))
              .buffer
              .asUint8List());
  
  await File("${dir.path}/icon.png")
      .writeAsBytes(
          (await rootBundle.load("assets/default_mod/icon.png"))
              .buffer
              .asUint8List());
}