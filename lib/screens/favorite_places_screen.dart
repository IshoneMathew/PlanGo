import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'destination_detail_screen.dart';

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({super.key});
  @override
  State<FavoritePlacesScreen> createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<List<Destination>>(
                stream: FirebaseService.destinationsStream(),
                builder: (context, snap) {
                  final favorites = (snap.data ?? [])
                      .where((d) => d.isBookmarked)
                      .toList();
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
                  }
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.bookmark_border, size: 64, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text('No bookmarked places yet',
                            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text('Bookmark destinations to find them here',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.grey)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) => _FavCard(
                      destination: favorites[i],
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: favorites[i]))),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        const Expanded(child: Center(
          child: Text('Bookmarked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        )),
        const SizedBox(width: 40),
      ]),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  const _FavCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: Image.network(destination.imageUrl,
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: Colors.grey.shade200)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(destination.name,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
                  const SizedBox(width: 2),
                  Expanded(child: Text(destination.location,
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey),
                      overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.star, size: 13),
                  const SizedBox(width: 3),
                  Text('${destination.rating}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('\$${destination.pricePerPerson.toInt()}/person',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ]),
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.bookmark, color: AppColors.primary, size: 20)),
        ]),
      ),
    );
  }
}
//favorite places screen by heshalaa