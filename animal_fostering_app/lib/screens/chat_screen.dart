import 'package:flutter/material.dart';
import '../theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: 100,
              color: primaryPurple.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Chat Support',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get help from our team',
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