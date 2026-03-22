import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/firebase_service.dart';
import 'destination_detail_screen.dart';

class PopularPlacesScreen extends StatelessWidget {
  const PopularPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSectionHeader(),
            Expanded(
              child: StreamBuilder<List<Destination>>(
                stream: FirebaseService.destinationsStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting && (snap.data ?? []).isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final destinations = snap.data ?? [];
                  if (destinations.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.place_outlined, size: 60, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text('No destinations yet', style: GoogleFonts.spaceGrotesk(fontSize: 15, color: AppColors.textSecondary)),
                      ]),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.72,
                      crossAxisSpacing: 14, mainAxisSpacing: 14),
                    itemCount: destinations.length,
                    itemBuilder: (_, i) => _PlaceCard(
                      destination: destinations[i],
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: destinations[i]))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.search, color: AppColors.textPrimary, size: 20)),
        ),
        const Expanded(child: Center(child: Text('Discover',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(children: [
        Text('Popular Places', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        Text('View All', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  const _PlaceCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(destination.imageUrl, height: 118, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 118, color: Colors.grey.shade200)),
            ),
            Positioned(top: 10, right: 10,
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseService.updateDestination(
                      destination.id, {'isFavorite': !destination.isFavorite});
                  },
                  child: Container(width: 30, height: 30,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: destination.isFavorite ? AppColors.red : AppColors.grey, size: 16)))),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(destination.name, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 11, color: AppColors.grey),
                const SizedBox(width: 2),
                Expanded(child: Text(destination.location,
                    style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey), overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.star, color: AppColors.star, size: 13),
                const SizedBox(width: 3),
                Text('${destination.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 4),
              Text('\$${destination.pricePerPerson.toInt()}/Person',
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ]),
      ),
    );
  }
}
//Done By Somidu