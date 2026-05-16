import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/storage_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final StorageService _storageService = StorageService();
  String? _idProofName;
  String? _selfieName;
  bool _isSubmitting = false;

  Future<void> _pickIdProof() async {
    final file = await _storageService.pickFromGallery();
    if (file != null && mounted) {
      setState(() => _idProofName = file.path.split('/').last);
    }
  }

  Future<void> _takeSelfie() async {
    final file = await _storageService.pickFromCamera();
    if (file != null && mounted) {
      setState(() => _selfieName = file.path.split('/').last);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification submitted successfully!'),
          backgroundColor: AppTheme.safeGreen,
        ),
      );
      Navigator.pop(context);
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

              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                  ),
                  Text('SafeNet AI', style: AppTheme.brandText),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.grey100),
                    child: const Icon(Icons.settings_outlined, color: AppTheme.grey600, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text('Identity Verification', style: AppTheme.headingLarge),
              const SizedBox(height: 10),
              Text(
                'To ensure maximum security for your account, we need to verify your identity. Your data is encrypted and stored in an isolated sanctuary.',
                style: AppTheme.bodyLarge,
              ),

              const SizedBox(height: 20),

              // Security standards info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withAlpha(25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SECURITY STANDARDS', style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w700, color: AppTheme.primaryBlue, letterSpacing: 0.5, fontSize: 11,
                          )),
                          const SizedBox(height: 4),
                          Text(
                            'Ensure your document is clearly visible and within the frame. Avoid glare and ensure high lighting for the selfie.',
                            style: AppTheme.bodySmall.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Upload ID Proof
              GestureDetector(
                onTap: _pickIdProof,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.grey200, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _idProofName != null ? Icons.check_circle : Icons.badge_outlined,
                          color: _idProofName != null ? AppTheme.safeGreen : AppTheme.primaryBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Upload ID Proof', style: AppTheme.headingSmall),
                      const SizedBox(height: 4),
                      Text(
                        _idProofName ?? 'Passport, Driver\'s License or National\nIdentity Card',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.grey300),
                        ),
                        child: Text(
                          _idProofName != null ? '✓ File Selected' : 'CHOOSE FILE',
                          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppTheme.grey600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Take Selfie
              GestureDetector(
                onTap: _takeSelfie,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.grey200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _selfieName != null ? Icons.check_circle : Icons.camera_alt_outlined,
                          color: _selfieName != null ? AppTheme.safeGreen : AppTheme.accentPurple,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Take a Selfie', style: AppTheme.headingSmall),
                      const SizedBox(height: 4),
                      Text(
                        _selfieName ?? 'A clear live photo to match your ID profile',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selfieName != null ? AppTheme.safeGreen.withAlpha(15) : AppTheme.dangerRed.withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selfieName != null ? '✓ Photo Captured' : 'OPEN CAMERA',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _selfieName != null ? AppTheme.safeGreen : AppTheme.dangerRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_idProofName != null || _selfieName != null) && !_isSubmitting ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerRed,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Submit for Approval', style: AppTheme.buttonText),
                ),
              ),

              const SizedBox(height: 16),

              // Footer info
              Center(
                child: Text(
                  'ESTIMATED PROCESSING TIME: 2-4 HRS',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400, fontSize: 10, letterSpacing: 1),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(icon: Icons.image, text: 'PNG, JPG or PDF'),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.data_usage, text: 'Max 10MB'),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.lock, text: '256-bit Encrypted'),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.grey500, size: 12),
          const SizedBox(width: 4),
          Text(text, style: AppTheme.bodySmall.copyWith(fontSize: 9, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
