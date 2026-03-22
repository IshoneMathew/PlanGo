import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final List<_EmergencyContact> _contacts = [
    _EmergencyContact(name: 'Police', number: '119', icon: Icons.local_police_outlined, color: const Color(0xFF1565C0), category: 'Emergency'),
    _EmergencyContact(name: 'Ambulance', number: '110', icon: Icons.local_hospital_outlined, color: const Color(0xFFC62828), category: 'Emergency'),
    _EmergencyContact(name: 'Fire Brigade', number: '111', icon: Icons.local_fire_department_outlined, color: const Color(0xFFE65100), category: 'Emergency'),
    _EmergencyContact(name: 'Tourist Police', number: '+94 11 2421052', icon: Icons.security_outlined, color: const Color(0xFF2E7D32), category: 'Tourism'),
    _EmergencyContact(name: 'Sri Lanka Tourism', number: '+94 11 2437059', icon: Icons.info_outlined, color: const Color(0xFF00838F), category: 'Tourism'),
    _EmergencyContact(name: 'Airport Hotline', number: '+94 19 733 5555', icon: Icons.flight_outlined, color: AppColors.primary, category: 'Transport'),
    _EmergencyContact(name: 'Medical Helpline', number: '1990', icon: Icons.medical_services_outlined, color: const Color(0xFF7B1FA2), category: 'Medical'),
  ];

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<_EmergencyContact>>{};
    for (final c in _contacts) {
      groups.putIfAbsent(c.category, () => []).add(c);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSosButton(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: groups.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 10),
                      child: Text(entry.key,
                          style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                    ...entry.value.map((c) => _ContactCard(contact: c)),
                  ],
                )).toList(),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
          ),
          const Expanded(child: Center(
            child: Text('Emergency Contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          )),
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.red, AppColors.red.withOpacity(0.8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOS Emergency', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Tap to call emergency services immediately',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showSosDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('CALL', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Call Emergency?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text('This will call the local emergency services (119).',
            style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size(80, 40)),
            child: Text('Call 119', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContact {
  final String name, number, category;
  final IconData icon;
  final Color color;
  const _EmergencyContact({required this.name, required this.number, required this.icon, required this.color, required this.category});
}

class _ContactCard extends StatelessWidget {
  final _EmergencyContact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: contact.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(contact.icon, color: contact.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(contact.number, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling ${contact.name}...'), backgroundColor: contact.color)),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: contact.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.call_outlined, color: contact.color, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
//emergency screen by heshalaa