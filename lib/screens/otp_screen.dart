import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
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
            children: [
              const SizedBox(height: 16),

              // Back + Brand
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                  ),
                  Text('SafeNet AI', style: AppTheme.brandText),
                ],
              ),

              const SizedBox(height: 48),

              // Shield icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withAlpha(20),
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryBlue, size: 30),
              ),

              const SizedBox(height: 28),

              Text('Verify Identity', style: AppTheme.headingLarge),
              const SizedBox(height: 10),
              Text(
                "We've sent a 6-digit security code to\nyour registered device.",
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge,
              ),

              const SizedBox(height: 40),

              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(14),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: AppTheme.grey50,
                  inactiveFillColor: AppTheme.grey50,
                  selectedFillColor: AppTheme.primaryBlue.withAlpha(10),
                  activeColor: AppTheme.primaryBlue,
                  inactiveColor: AppTheme.grey200,
                  selectedColor: AppTheme.primaryBlue,
                ),
                textStyle: AppTheme.headingMedium,
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onCompleted: (_) => _verifyOtp(),
                onChanged: (_) {},
              ),

              const SizedBox(height: 28),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Verify', style: AppTheme.buttonText),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              Text("Didn't receive the code? Check your spam", style: AppTheme.bodySmall),
              const SizedBox(height: 4),
              const Text('or'),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {},
                child: Text(
                  '↻ Resend Code',
                  style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue),
                ),
              ),

              const SizedBox(height: 8),

              // Skip for demo
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.roleSelection),
                child: Text(
                  'Skip for Demo →',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400, decoration: TextDecoration.underline),
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Text(
                '🔒 SECURED BY SAFENET END-TO-END',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400, fontSize: 10, letterSpacing: 1),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
