import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'edit_profile_screen.dart';
import 'favorite_places_screen.dart';
import 'my_trips_screen.dart';
import 'emergency_screen.dart';
import 'ai_assistant_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, auth),
              _buildAvatar(auth),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 28),
              _buildMenuItems(context, auth),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, app_auth.AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
          ),
          const Expanded(child: Center(
            child: Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          )),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(app_auth.AuthProvider auth) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.grey.shade300,
              child: auth.photoUrl.isNotEmpty
                  ? ClipOval(child: Image.network(auth.photoUrl, width: 104, height: 104, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(auth)))
                  : _avatarPlaceholder(auth),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(auth.displayName,
                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (auth.isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shield_rounded, color: Colors.white, size: 11),
                  const SizedBox(width: 3),
                  Text('Admin', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(auth.email,
            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _avatarPlaceholder(app_auth.AuthProvider auth) {
    final initials = auth.displayName.isNotEmpty
        ? auth.displayName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : '?';
    return Container(
      width: 104, height: 104,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
      child: Center(child: Text(initials, style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white))),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            _StatCell(label: 'Reward Points', value: '360'),
            Container(width: 1, height: 50, color: AppColors.divider),
            _StatCell(label: 'Travel Trips', value: '238'),
            Container(width: 1, height: 50, color: AppColors.divider),
            _StatCell(label: 'Bucket List', value: '473'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, app_auth.AuthProvider auth) {
    final items = <_MenuItem>[
      if (auth.isAdmin)
        _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Dashboard',
            badge: 'ADMIN', badgeColor: AppColors.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()))),
      _MenuItem(icon: Icons.person_outline, label: 'Edit Profile',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
      _MenuItem(icon: Icons.bookmark_border, label: 'Bookmarked',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritePlacesScreen()))),
      _MenuItem(icon: Icons.flight_outlined, label: 'My Trips',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen()))),
      _MenuItem(icon: Icons.auto_awesome_outlined, label: 'AI Assistant',
          badge: 'NEW', badgeColor: AppColors.primary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()))),
      _MenuItem(icon: Icons.emergency_outlined, label: 'Emergency Contacts',
          badgeColor: AppColors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()))),
      _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
      _MenuItem(icon: Icons.logout, label: 'Sign Out', isDestructive: true,
          onTap: () async {
            final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
              title: Text('Sign Out', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
              content: Text('Are you sure you want to sign out?', style: GoogleFonts.spaceGrotesk()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true),
                    child: Text('Sign Out', style: TextStyle(color: AppColors.red))),
              ],
            ));
            if (confirm == true && context.mounted) {
              await context.read<app_auth.AuthProvider>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()), (_) => false);
            }
          }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: items.asMap().entries.map((e) => Column(children: [
            _MenuRow(item: e.value),
            if (e.key < items.length - 1)
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.divider)),
          ])).toList(),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  const _StatCell({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    ),
  );
}

class _MenuItem {
  final IconData icon; final String label; final String? badge; final Color? badgeColor;
  final VoidCallback onTap; final bool isDestructive;
  const _MenuItem({required this.icon, required this.label, required this.onTap,
      this.badge, this.badgeColor, this.isDestructive = false});
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  const _MenuRow({required this.item});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: item.onTap, behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: item.isDestructive ? AppColors.red.withOpacity(0.08) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: item.isDestructive ? AppColors.red : AppColors.textSecondary, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Text(item.label,
            style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500,
                color: item.isDestructive ? AppColors.red : AppColors.textPrimary))),
        if (item.badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: item.badgeColor ?? AppColors.green, borderRadius: BorderRadius.circular(20)),
            child: Text(item.badge!, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          )
        else if (item.badgeColor != null && !item.isDestructive) ...[
          Container(width: 8, height: 8, decoration: BoxDecoration(color: item.badgeColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
        ] else if (!item.isDestructive)
          const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
      ]),
    ),
  );
}//done by chamadith
