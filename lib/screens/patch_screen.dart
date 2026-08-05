import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:file_picker/file_picker.dart";
import "package:path_provider/path_provider.dart";

import "../widgets/navigation_buttons.dart";
import "../patcher/patcher.dart";

class PatchScreen extends StatefulWidget {
  const PatchScreen({super.key});

  @override
  State<PatchScreen> createState() => _PatchScreenState();
}

class _PatchScreenState extends State<PatchScreen> {
  String? _selectedApkPath;
  bool _isPatching = false;

  Future<String> _extractAssetToFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes, 
      byteData.lengthInBytes,
    );

    debugPrint('Asset $assetPath loaded successfully! Size: ${bytes.length} bytes');

    if (bytes.length < 10) {
      throw Exception('Asset $assetPath seems too small. Possible loading error.');
    }

    await file.writeAsBytes(
      bytes,
    );
    return file.path;
  }

  Future<void> _pickApkFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final selectedPath = result.files.single.path;

      if (selectedPath != null && selectedPath.endsWith('.apk')) {
        setState(() {
          _selectedApkPath = selectedPath;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid APK file.')),
        );
      }
    }
  }

  Future<void> _patchApk() async {
    if (_selectedApkPath == null) return;

    setState(() {
      _isPatching = true;
    });

    try {
      final libil2cppPath = await _extractAssetToFile('assets/patch_files/libil2cpp.so', 'libil2cpp.so');
      final libloaderPath = await _extractAssetToFile('assets/patch_files/libloader.so', 'libloader.so');
      final libpayloadPath = await _extractAssetToFile('assets/patch_files/libpayload.so', 'libpayload.so');
      final dexPath = await _extractAssetToFile('assets/patch_files/classes.dex', 'classes.dex');
      final androidManifestPath = await _extractAssetToFile('assets/patch_files/AndroidManifest.xml', 'AndroidManifest.xml');

      final tempDir = await getTemporaryDirectory();

      final patcher = ApkPatcher(
        libil2cpp_patched_path: libil2cppPath,
        libloader_path: libloaderPath,
        libpayload_path: libpayloadPath,
        java_dex_path: dexPath,
        android_manifest_path: androidManifestPath,
      );

      final unsignedApk = await patcher.patchApk(_selectedApkPath!, tempDir.path);

      final outputDir = await getExternalStorageDirectory();
      final signedApkPath = '${outputDir!.path}/signed_output.apk';

      const platform = MethodChannel('apk_signer');
      final signedResult = await platform.invokeMethod('signApk', {
        'inputPath': unsignedApk,
        'outputPath': signedApkPath,
        'keystorePassword': '123456',
        'keyAlias': 'picka',
        'keyPassword': '123456',
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Done: $signedResult')));
      }
    } catch (e, stackTrace) {
      debugPrint(' Error details: $e');
      debugPrint(' StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPatching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text("Choose apk to patch", style: TextStyle(fontSize: 24)),

            if (_selectedApkPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _selectedApkPath!.split('/').last,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _pickApkFile,
              icon: const Icon(Icons.folder_open),
              label: const Text("Select APK"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: (_selectedApkPath == null || _isPatching)
                  ? null
                  : _patchApk,
              icon: _isPatching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.build),
              label: Text(_isPatching ? "Patching..." : "Patch apk"),
            ),

            const SizedBox(height: 100),

            const Text(
              "Patched APK will be saved in Android/data/com.picka.launcher/files.\n Also, you need to give storage permission to Terraria after patching!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
      bottomNavigationBar: const NavigationButtons(),
    );
  }
}
