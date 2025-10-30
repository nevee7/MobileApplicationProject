import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(AnimalFosteringApp());
}

class AnimalFosteringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Fostering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(), // Removed 'const'
      debugShowCheckedModeBanner: false,
    );
  }
}