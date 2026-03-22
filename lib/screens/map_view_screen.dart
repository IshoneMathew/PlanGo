import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class MapViewScreen extends StatelessWidget {
  final Destination destination;
  const MapViewScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Aerial map background image
          Image.network(
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2C5F2E),
            ),
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.25)),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            const Icon(Icons.chevron_left, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          // Map pin cards
          Positioned(
            top: 160,
            left: 80,
            child: _MapPinCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=200&q=80',
              name: 'La-Hotel',
              distance: '2.09 mi',
            ),
          ),
          Positioned(
            top: 260,
            left: 20,
            child: _MapPinCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=200&q=80',
              name: 'Lemon Garden',
              distance: '2.09 mi',
            ),
          ),

          // Blue pin dots
          Positioned(
            top: 205,
            right: 100,
            child: _BlueDot(),
          ),
          Positioned(
            bottom: 310,
            left: 40,
            child: _BlueDot(large: true),
          ),

          // Bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2332),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.white60, size: 14),
                                const SizedBox(width: 4),
                                Text(destination.location,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white60, size: 14),
                                const SizedBox(width: 4),
                                Text('45 Minutes',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: AppColors.star, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${destination.rating}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _TravelerStack(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.greenGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'See On The Map',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

class _MapPinCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String distance;
  const _MapPinCard({
    required this.imageUrl,
    required this.name,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332).withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 44, height: 44, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              const SizedBox(height: 2),
              Text(distance,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white60,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlueDot extends StatelessWidget {
  final bool large;
  const _BlueDot({this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 16.0 : 12.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2),
        ],
      ),
    );
  }
}

class _TravelerStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const urls = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=50&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=50&q=80',
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=50&q=80',
    ];
    return SizedBox(
      width: 68,
      height: 24,
      child: Stack(
        children: [
          ...urls.asMap().entries.map((e) => Positioned(
                left: e.key * 16.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundImage: NetworkImage(e.value),
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              )),
          Positioned(
            left: 48,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text('+50',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
} //build by gavesha
