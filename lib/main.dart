import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/patch_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      },
      // home: const HomePage(),
    );
  }
}

