// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    // Short demo flow — replace with real auth
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          children: [
            const SizedBox(height: 8),
            Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: cuteGradient,
                    boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.18), blurRadius: 18, offset: Offset(0, 8))],
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                const Text('PawsConnect', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Find loving homes for pets in Timișoara', style: TextStyle(color: textSecondary)),
              ],
            ),
            const SizedBox(height: 36),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: Text('Skip for demo', style: TextStyle(color: primaryViolet)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
