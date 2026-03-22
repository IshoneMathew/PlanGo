import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'map_view_screen.dart';
import 'checkout_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;
  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  bool _isBookmarked = false;
  bool _expanded = false;
  int _selectedGallery = 0;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.destination.isBookmarked;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    super.dispose();
  }

  Future<void> _toggleBookmark() async {
    final newVal = !_isBookmarked;
    setState(() => _isBookmarked = newVal);
    try {
      await FirebaseService.updateDestination(
        widget.destination.id,
        {'isBookmarked': newVal},
      );
    } catch (_) {
      // Revert on failure
      if (mounted) setState(() => _isBookmarked = !newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.destination;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero image
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.black54,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                ),
                title: Text('Details',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    )),
                actions: [
                  GestureDetector(
                    onTap: () => _toggleBookmark(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(d.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade400)),
                      Container(
                        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 16),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(d.location,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80',
                              ),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(d.location,
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.grey)),
                            const SizedBox(width: 16),
                            const Icon(Icons.star, size: 14, color: AppColors.star),
                            const SizedBox(width: 4),
                            Text('${d.rating}(${d.reviews})',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                )),
                            const Spacer(),
                            Text('\$${d.pricePerPerson.toInt()}/Person',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Gallery
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...d.galleryImages.asMap().entries.map((e) {
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedGallery = e.key),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: _selectedGallery == e.key
                                          ? Border.all(color: AppColors.primary, width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        e.value,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(width: 70, height: 70, color: Colors.grey.shade200),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text('+10',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('About Destination',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.description,
                              maxLines: _expanded ? null : 4,
                              overflow: _expanded ? null : TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.7,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _expanded = !_expanded),
                              child: Text(
                                _expanded ? 'Show less' : 'Read more',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Book Now Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Book Now',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MapViewScreen(destination: d)),
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
