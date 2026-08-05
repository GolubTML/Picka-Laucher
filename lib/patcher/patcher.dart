import "dart:io";
import "package:archive/archive_io.dart";
import "package:flutter/services.dart";

class ApkPatcher {
  final String libil2cpp_patched_path;
  final String libloader_path;
  final String libpayload_path;
  final String java_dex_path;
  final String android_manifest_path;

  ApkPatcher({
    required this.libil2cpp_patched_path,
    required this.libloader_path,
    required this.libpayload_path,
    required this.java_dex_path,
    required this.android_manifest_path,
  });

  Future<String> patchApk(String originalApkPath, String tempDirPath) async {
    final workDir = Directory('$tempDirPath/apk_patch_${DateTime.now().millisecondsSinceEpoch}');
    final unpackDir = Directory('${workDir.path}/unpacked');
    await unpackDir.create(recursive: true);

    await _unpackApk(originalApkPath, unpackDir.path);

    final existingDexCount = unpackDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dex'))
        .length;
    final newDexName = 'classes${existingDexCount + 1}.dex';
    await File(java_dex_path).copy('${unpackDir.path}/$newDexName');

    final libDir = Directory('${unpackDir.path}/lib/arm64-v8a');
    await libDir.create(recursive: true);

    await File(libloader_path).copy('${libDir.path}/${File(libloader_path).uri.pathSegments.last}');
    await File(libpayload_path).copy('${libDir.path}/${File(libpayload_path).uri.pathSegments.last}');

    final patchedTargetName = File(libil2cpp_patched_path).uri.pathSegments.last;
    await File(libil2cpp_patched_path).copy('${libDir.path}/$patchedTargetName');

    final manifest = File(android_manifest_path).uri.pathSegments.last;
    await File(android_manifest_path).copy('${unpackDir.path}/$manifest');
    
    final metaInfDir = Directory('${unpackDir.path}/META-INF');
    if (await metaInfDir.exists()) {
      await metaInfDir.delete(recursive: true);
    }

    final unsignedApk = '${workDir.path}/unsigned.apk';
    await _repackApk(unpackDir.path, unsignedApk);

    return unsignedApk;
  }

  Future<void> _unpackApk(String apkPath, String outputDir) async {
    const platform = MethodChannel('apk_signer');
    await platform.invokeMethod('unpackApk', {
      'apkPath': apkPath,
      'outputDir': outputDir,
    });
  }

  Future<void> _repackApk(String sourceDir, String outputApkPath) async {
    const platform = MethodChannel('apk_signer');
    await platform.invokeMethod('repackApk', {
      'inputDir': sourceDir,
      'outputApk': outputApkPath,
    });
  }
}