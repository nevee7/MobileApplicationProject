import 'package:flutter/material.dart';
import '../theme.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 100,
              color: primaryPurple.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'My Applications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Track your adoption requests',
              style: TextStyle(
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}