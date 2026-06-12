import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MsmeApp());
}

class MsmeApp extends StatelessWidget {
  const MsmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1565C0); // Dark blue per prototype PDF

    return MaterialApp(
      title: 'MSME Logistik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const MainScreen(),
    );
  }
}
