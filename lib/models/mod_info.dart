class ModInfo {
  final String name;
  final String version;
  final String description;
  final String author;

  final String iconPath;
  final String folderPath;

  ModInfo({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.iconPath,
    required this.folderPath,
  });

  factory ModInfo.fromJson(
    Map<String, dynamic> json, 
    { required String folderPath, }) 
  {
    return ModInfo(
      name: json['name'] ?? "Unknow Mod",
      version: json['version'] ?? "1.0.0",
      description: json['description'] ?? "No description available.",
      author: json['author'] ?? "Unknown Author",
      iconPath: '$folderPath/icon.png',
      folderPath: folderPath,
    );
  }
}