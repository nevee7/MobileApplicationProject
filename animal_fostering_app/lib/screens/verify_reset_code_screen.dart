import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'reset_password_screen.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String token;

  const VerifyResetCodeScreen({super.key, required this.token});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    
    // Auto-submit when all fields are filled
    if (_getCode().length == 6) {
      _submit();
    }
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _submit() async {
    final code = _getCode();
    if (code.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final verifiedToken = await AuthService.verifyResetCode(widget.token, code);
      
      // Navigate to reset password screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: verifiedToken),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      // Clear all fields on error
      for (var controller in _controllers) {
        controller.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
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
              'Enter Verification Code',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to your email',
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            // Code input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => _onChanged(index, value),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Verify button
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
                    : const Text('Verify Code', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resend code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive code?",
                  style: TextStyle(color: textSecondary),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    // Implement resend logic
                  },
                  child: const Text('Resend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}