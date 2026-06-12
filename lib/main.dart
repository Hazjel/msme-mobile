import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MsmeApp());
}

class MsmeApp extends StatelessWidget {
  const MsmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSME Logistik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
