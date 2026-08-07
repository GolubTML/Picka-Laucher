import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/patch_screen.dart';
import 'screens/mods_screen.dart';

import '../services/permission.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
   void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await PermissionsService.requestStoragePermission();
    await PermissionsService.requestAPKInstallationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picka Launcher',
      theme: ThemeData(
        brightness: Brightness.dark,
        
        scaffoldBackgroundColor: Colors.black,

        colorScheme: const ColorScheme.dark(
          primary: Colors.grey,
          secondary: Colors.grey,
          surface: Color(0xff121212),
        ),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/patch': (context) => const PatchScreen(),
        '/mods': (context) => const ModsPage(),
      },
      // home: const HomePage(),
    );
  }
}

