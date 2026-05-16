import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.otp);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Signup failed'), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                  ),
                  Text('SafeNet AI', style: AppTheme.brandText),
                ],
              ),

              const SizedBox(height: 32),

              Text('Create Account', style: AppTheme.headingLarge),
              const SizedBox(height: 8),
              Text('Join the SafeNet protection network.', style: AppTheme.bodyLarge),

              const SizedBox(height: 32),

              // Full Name
              Text('FULL NAME', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: AppTheme.grey700)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.grey400, size: 20),
                ),
              ),

              const SizedBox(height: 20),

              // Phone
              Text('PHONE NUMBER', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: AppTheme.grey700)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.grey400, size: 20),
                ),
              ),

              const SizedBox(height: 20),

              // Email
              Text('EMAIL', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: AppTheme.grey700)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.grey400, size: 20),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Text('PASSWORD', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: AppTheme.grey700)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.grey400, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.grey400, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign Up
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Create Account', style: AppTheme.buttonText),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?  ', style: AppTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Sign in', style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue)),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
