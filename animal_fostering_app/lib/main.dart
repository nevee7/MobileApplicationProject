// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/add_animal_screen.dart';
import 'screens/animal_details_screen.dart';
import 'models/animal.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
          secondary: primaryViolet,
          background: backgroundColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryPurple,
            side: BorderSide(color: primaryPurple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: textSecondary),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryPurple,
          unselectedItemColor: Colors.grey,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.grey[800],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: primaryPurple,
          linearTrackColor: primaryPurple.withOpacity(0.2),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey[800],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const DashboardScreen(),
        '/animals': (context) => const AnimalListScreen(),
        '/add': (context) => const AddAnimalScreen(),
        '/animal-details': (context) {
          final animal = ModalRoute.of(context)!.settings.arguments as Animal;
          return AnimalDetailsScreen(animal: animal);
        },
      },
      onGenerateRoute: (settings) {
        // Handle any custom routes or deep linking here
        switch (settings.name) {
          case '/animal-details':
            final animal = settings.arguments as Animal;
            return MaterialPageRoute(
              builder: (context) => AnimalDetailsScreen(animal: animal),
            );
          default:
            return null;
        }
      },
      onUnknownRoute: (settings) {
        // Fallback route for unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Page not found',
                    style: TextStyle(fontSize: 18, color: textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside of text fields
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.focusedChild?.unfocus();
            }
          },
          child: child,
        );
      },
    );
  }
}