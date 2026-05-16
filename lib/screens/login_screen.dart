import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: AppTheme.dangerRed,
          ),
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
              const SizedBox(height: 20),

              // Brand
              Text('SafeNet AI', style: AppTheme.brandText.copyWith(fontSize: 22)),

              const SizedBox(height: 48),

              // Welcome
              Text('Welcome Back', style: AppTheme.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to access your\nsecure space.',
                style: AppTheme.bodyLarge,
              ),

              const SizedBox(height: 40),

              // Email
              Text('PHONE OR EMAIL', style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppTheme.grey700,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'guardian@safenet.ai',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.grey400, size: 20),
                ),
              ),

              const SizedBox(height: 24),

              // Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PASSWORD', style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppTheme.grey700,
                  )),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot Password?',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.grey400, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.grey400,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Continue', style: AppTheme.buttonText),
                ),
              ),

              const SizedBox(height: 28),

              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.grey200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400)),
                  ),
                  Expanded(child: Divider(color: AppTheme.grey200)),
                ],
              ),

              const SizedBox(height: 28),

              // OTP verification
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.otp),
                  icon: const Icon(Icons.sms_outlined, size: 20),
                  label: const Text('OTP Verification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.grey700,
                    side: BorderSide(color: AppTheme.grey200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?  ", style: AppTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: Text(
                      'Sign up',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Legal
              Text(
                'By continuing, you agree to SafeNet AI\'s Security Protocols and Privacy Policy. All data is encrypted end-to-end.',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400, fontSize: 11),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
