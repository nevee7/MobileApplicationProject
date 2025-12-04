import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showChangePassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset form
      _formKey.currentState!.reset();
      setState(() => _showChangePassword = false);
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
    final user = AuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: cuteGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user?.isAdmin == true 
                          ? Colors.purple.withOpacity(0.1) 
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role ?? 'User',
                      style: TextStyle(
                        color: user?.isAdmin == true ? primaryPurple : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Profile info
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildInfoItem('Email', user?.email ?? ''),
            _buildInfoItem('Phone', user?.phone ?? 'Not provided'),
            _buildInfoItem('Address', user?.address ?? 'Not provided'),
            _buildInfoItem('Member since', 'Recently joined'),
            
            const SizedBox(height: 32),
            
            // Change password section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showChangePassword 
                                ? Icons.expand_less 
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() => _showChangePassword = !_showChangePassword);
                          },
                        ),
                      ],
                    ),
                    
                    if (_showChangePassword) ...[
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: _obscureCurrentPassword,
                              decoration: InputDecoration(
                                labelText: 'Current Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureCurrentPassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter current password';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                prefixIcon: const Icon(Icons.lock_reset),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm new password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Update Password', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Card(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildActionItem(
                    icon: Icons.security,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                  _buildActionItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildActionItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      AuthService.logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? primaryPurple),
      title: Text(title, style: TextStyle(color: color ?? textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}