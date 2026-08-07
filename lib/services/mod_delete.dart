import "dart:io";

Future<void> deleteMod(String folderPath) async {
  final dir = Directory(folderPath);

  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}