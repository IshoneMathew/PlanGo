import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  bool _saving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final auth = context.read<app_auth.AuthProvider>();
    _nameCtrl     = TextEditingController(text: auth.displayName);
    _phoneCtrl    = TextEditingController(text: auth.profile?['phone'] ?? '');
    _locationCtrl = TextEditingController(text: auth.profile?['location'] ?? 'Sri Lanka');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty.');
      return;
    }
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      await FirebaseService.updateUserProfile({
        'name': name,
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      await context.read<app_auth.AuthProvider>().refreshProfile();
      if (mounted) setState(() { _saving = false; _success = 'Profile updated!'; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = 'Failed to save: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final initials = auth.displayName.split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 90, height: 90,
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                      child: Center(child: Text(initials,
                          style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white))),
                    ),
                    const SizedBox(height: 8),
                    Text(auth.email,
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
                    if (auth.isAdmin) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text('Admin Account', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // Success/Error banners
                    if (_success != null) _banner(_success!, AppColors.green, Icons.check_circle_outline),
                    if (_error != null) _banner(_error!, AppColors.red, Icons.error_outline),

                    // Form fields
                    _formCard([
                      _Field(label: 'Full Name', controller: _nameCtrl, icon: Icons.person_outline),
                      _Field(label: 'Phone Number', controller: _phoneCtrl, icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone),
                      _Field(label: 'Location', controller: _locationCtrl, icon: Icons.location_on_outlined),
                    ]),

                    const SizedBox(height: 14),

                    // Read-only email
                    _formCard([
                      _ReadOnlyField(label: 'Email Address', value: auth.email, icon: Icons.mail_outline),
                    ]),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _saving
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save Changes',
                              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        const Expanded(child: Center(
          child: Text('Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        )),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _banner(String msg, Color color, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: color))),
    ]),
  );

  Widget _formCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
    child: Column(children: children.asMap().entries.map((e) => Column(children: [
      e.value,
      if (e.key < children.length - 1)
        const Divider(height: 1, indent: 20, color: AppColors.divider),
    ])).toList()),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboard;
  const _Field({required this.label, required this.controller, required this.icon,
      this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboard,
        style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4))),
          filled: false,
        ),
      ),
    ]),
  );
}

class _ReadOnlyField extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _ReadOnlyField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Row(children: [
      Icon(icon, color: AppColors.grey, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6)),
          child: Text('Read only', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.grey))),
    ]),
  );
}
//edit profile screen by heshala