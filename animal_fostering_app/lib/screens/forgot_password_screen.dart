import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'verify_reset_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final token = await AuthService.forgotPassword(_emailController.text);
      setState(() => _resetToken = token);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset code sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyResetCodeScreen(token: token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Reset Password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we\'ll send you a code to reset your password.',
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            // Form
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Code', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back to login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}