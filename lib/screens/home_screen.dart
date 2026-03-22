import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'destination_detail_screen.dart';
import 'notification_screen.dart';
import 'popular_places_screen.dart';
import 'ai_assistant_screen.dart';
import 'planner_wizard_screen.dart';
import 'my_trips_screen.dart';
import 'emergency_screen.dart';
import 'route_planner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<Destination>>(
          stream: FirebaseService.destinationsStream(),
          builder: (context, snap) {
            final destinations = snap.data ?? [];
            final loading = snap.connectionState == ConnectionState.waiting && destinations.isEmpty;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildHeroTitle()),
                SliverToBoxAdapter(child: _buildSearchBar(context)),
                SliverToBoxAdapter(child: _buildQuickFeatures(context)),
                if (loading)
                  const SliverToBoxAdapter(child: _LoadingShimmer())
                else if (destinations.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _buildSectionHeader(context, 'Best Destination', 'View all',
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PopularPlacesScreen())))),
                  SliverToBoxAdapter(child: _buildBestDestinations(context, destinations)),
                  SliverToBoxAdapter(child: _buildSectionHeader(context, 'Popular Places', 'View all',
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PopularPlacesScreen())))),
                  SliverToBoxAdapter(child: _buildPopularPlaces(context, destinations)),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final name = auth.displayName;
    final initials = name.split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
            child: Row(children: [
              auth.photoUrl.isNotEmpty
                  ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(auth.photoUrl), backgroundColor: AppColors.primaryLight)
                  : CircleAvatar(radius: 16, backgroundColor: AppColors.primary,
                      child: Text(initials, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
              const SizedBox(width: 8),
              Row(children: [
                Text(name.split(' ').first,
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (auth.isAdmin) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(6)),
                    child: Text('Admin', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ]),
            ]),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
            child: Stack(children: [
              Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22)),
              Positioned(top: 10, right: 10,
                  child: Container(width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Explore the Beautiful',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
        Text('Sri Lanka',
            style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent)),
      ]),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutePlannerScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))]),
          child: Row(children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.my_location_rounded, color: AppColors.green, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Where are you starting from?',
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Pick a destination in Sri Lanka',
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 18)),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuickFeatures(BuildContext context) {
    final features = [
      _Feature('AI\nAssistant', Icons.auto_awesome_rounded,
          const LinearGradient(colors: [Color(0xFF006FFD), Color(0xFF00C6FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()))),
      _Feature('Plan\nTrip', Icons.map_outlined,
          const LinearGradient(colors: [Color(0xFF134E5E), Color(0xFF71B280)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerWizardScreen()))),
      _Feature('My\nTrips', Icons.flight_takeoff_outlined,
          const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen()))),
      _Feature('Emergency', Icons.emergency_outlined,
          const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()))),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: features.asMap().entries.map((e) {
          final f = e.value;
          final isLast = e.key == features.length - 1;
          return Expanded(
            child: GestureDetector(
              onTap: f.onTap,
              child: Container(
                margin: EdgeInsets.only(right: isLast ? 0 : 10),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: f.gradient, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: f.gradient.colors.first.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f.icon, color: Colors.white, size: 26),
                  const SizedBox(height: 6),
                  Text(f.label, textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        GestureDetector(onTap: onTap,
            child: Text(action, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildBestDestinations(BuildContext context, List<Destination> destinations) {
    final items = destinations.take(4).toList();
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final d = items[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d))),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16, bottom: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(fit: StackFit.expand, children: [
                  Image.network(d.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
                  Container(decoration: const BoxDecoration(gradient: AppColors.darkGradient)),
                  Positioned(top: 12, right: 12,
                      child: Container(width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Icon(d.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 18))),
                  Positioned(bottom: 14, left: 14, right: 14,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 12),
                          const SizedBox(width: 2),
                          Expanded(child: Text(d.province,
                              style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 11),
                              overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.star, color: AppColors.star, size: 13),
                          const SizedBox(width: 3),
                          Text('${d.rating}', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          _TravelerAvatars(count: d.travelers),
                        ]),
                      ])),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularPlaces(BuildContext context, List<Destination> destinations) {
    final items = destinations.skip(2).take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((d) => GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))]),
            child: Row(children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                child: Image.network(d.imageUrl, width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: Colors.grey.shade200)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.name, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
                      const SizedBox(width: 2),
                      Expanded(child: Text(d.location,
                          style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: AppColors.star, size: 13),
                      const SizedBox(width: 3),
                      Text('${d.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const Spacer(),
                      Text('\$${d.pricePerPerson.toInt()}/Person',
                          style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}

class _TravelerAvatars extends StatelessWidget {
  final int count;
  const _TravelerAvatars({required this.count});
  static const _urls = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=50&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=50&q=80',
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=50&q=80',
  ];
  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 52, height: 20,
        child: Stack(children: _urls.asMap().entries.map((e) => Positioned(
          left: e.key * 14.0,
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
            child: CircleAvatar(radius: 9, backgroundImage: NetworkImage(e.value), backgroundColor: Colors.grey.shade300)),
        )).toList())),
    Text('+$count', style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 10)),
  ]);
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(children: [
      Container(height: 240, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(20))),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Container(height: 90, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)))),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 90, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)))),
      ]),
    ]),
  );
}

class _Feature {
  final String label; final IconData icon; final LinearGradient gradient; final VoidCallback onTap;
  const _Feature(this.label, this.icon, this.gradient, this.onTap);
}//done by nikil
