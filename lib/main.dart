import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MetroFixApp());
}

class MetroFixApp extends StatelessWidget {
  const MetroFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroFix - QR Metro Asset Maintenance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0284C7),
          onPrimary: Colors.white,
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
          error: Color(0xFFEF4444),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E293B),
        fontFamily: null,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
