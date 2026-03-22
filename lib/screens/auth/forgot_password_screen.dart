import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _reset() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email address.'); return;
    }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<app_auth.AuthProvider>();
    final err = await auth.resetPassword(_emailCtrl.text.trim());
    if (mounted) setState(() { _loading = false; _error = err; _sent = err == null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(bottom: -60, left: -40, right: -40,
              child: Container(height: 300,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.06)))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 52),
                  Center(child: Text('Forgot password', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  const SizedBox(height: 10),
                  Center(child: Text('Enter your email to reset your password',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary))),
                  const SizedBox(height: 40),

                  if (_sent) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.green.withOpacity(0.3))),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.green),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Reset email sent! Check your inbox.',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.green, fontWeight: FontWeight.w500))),
                      ]),
                    ),
                  ] else ...[
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.red.withOpacity(0.3))),
                        child: Text(_error!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.red)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary, size: 20)),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Send Reset Email', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
