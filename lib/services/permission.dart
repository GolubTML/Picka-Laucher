import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  static Future<bool> requestAPKInstallationPermission() async {
    if (await Permission.requestInstallPackages.isGranted) {
      return true;
    }

    final status = await Permission.requestInstallPackages.request();
    return status.isGranted;
  }
}