import 'package:animal_fostering_app/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';
import 'screens/map_screen.dart';
import 'screens/my_applications_screen.dart';
import 'services/auth_service.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart'; // Add this import
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart'; // Add this import
import 'screens/verify_reset_code_screen.dart'; // Add this import
import 'screens/reset_password_screen.dart'; // Add this import
import 'screens/profile_screen.dart'; // Add this import
import 'screens/dashboard_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/add_animal_screen.dart';
import 'screens/animal_details_screen.dart';
import 'models/animal.dart';
import 'screens/admin_manage_applications_screen.dart';
import 'screens/admin_manage_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
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
            borderSide: const BorderSide(color: primaryPurple, width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(), // Changed from AuthWrapper
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-reset-code': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return VerifyResetCodeScreen(token: token);
        },
        '/reset-password': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return ResetPasswordScreen(token: token);
        },
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const DashboardScreen(),
        '/animals': (context) => const AnimalListScreen(),
        '/map': (context) => const MapScreen(),
        '/my-applications': (context) => const MyApplicationsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/add-animal': (context) => const AddAnimalScreen(),
        '/animal-details': (context) {
          final animal = ModalRoute.of(context)!.settings.arguments as Animal;
          return AnimalDetailsScreen(animal: animal);
        },
        '/admin/applications': (context) => const AdminManageApplicationsScreen(),
        '/admin/users': (context) => const AdminManageUsersScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn 
        ? const DashboardScreen()
        : const WelcomeScreen(); // Changed from LoginScreen
  }
}