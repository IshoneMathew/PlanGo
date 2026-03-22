import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../screens/main_nav_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final auth = context.read<app_auth.AuthProvider>();
    final err  = await auth.signIn(email, pass);

    if (!mounted) return;

    if (err != null) {
      // Sign-in failed — show error
      setState(() { _loading = false; _error = err; });
    } else {
      // Sign-in succeeded — navigate based on role
      _navigateHome(auth);
    }
  }

  void _navigateHome(app_auth.AuthProvider auth) {
    if (auth.isAdmin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen(isHome: true)),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(bottom: -60, left: -40, right: -40,
              child: Container(height: 300,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.06)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Center(
                    child: Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome back', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Sign in to continue your Sri Lanka journey',
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),

                  // Error banner
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.red.withOpacity(0.3))),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.red))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline, color: AppColors.grey, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signIn(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.grey, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: Text('Forgot Password?',
                          style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In button
                  ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Sign In',
                            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: "Don't have an account? ",
                              style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary)),
                          TextSpan(text: 'Sign up',
                              style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
