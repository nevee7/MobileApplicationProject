// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/add_animal_screen.dart';

void main() {
  runApp(const AnimalFosteringApp());
}

class AnimalFosteringApp extends StatelessWidget {
  const AnimalFosteringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawsConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const DashboardScreen(),
        '/animals': (_) => const AnimalListScreen(),
        '/add': (_) => const AddAnimalScreen(),
      },
    );
  }
}
