import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/trip_service.dart';
import '../models/trip_models.dart';
import 'my_trips_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<BookedTrip>>(
              stream: TripService.userTripsStream(),
              builder: (context, snap) {
                final trips = (snap.data ?? [])
                    .where((t) => t.pendingOffer != null)
                    .toList();

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
                }

                if (trips.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.grey),
                    const SizedBox(height: 16),
                    Text('No messages yet', style: GoogleFonts.spaceGrotesk(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text('Admin messages about your trips\nwill appear here',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.grey)),
                  ]));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MessageCard(trip: trips[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Messages', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Admin communications about your trips',
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final BookedTrip trip;
  const _MessageCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final offer = trip.pendingOffer!;
    final isPending = offer.offerStatus == 'pending';
    final isAccepted = offer.offerStatus == 'accepted';
    final statusColor = isPending ? AppColors.warning : isAccepted ? AppColors.green : AppColors.grey;
    final statusLabel = isPending ? 'Action Required' : isAccepted ? 'Accepted' : 'Declined';

    final now = DateTime.now();
    final diff = now.difference(offer.sentAt);
    final timeStr = diff.inMinutes < 60 ? '${diff.inMinutes}m ago'
        : diff.inHours < 24 ? '${diff.inHours}h ago'
        : '${diff.inDays}d ago';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          border: isPending ? Border.all(color: AppColors.warning.withOpacity(0.35)) : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 42, height: 42,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.support_agent, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PlanGo Admin', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('Re: ${trip.destination}', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(timeStr, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel,
                      style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor))),
            ]),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Text('"${offer.message}"',
              style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.5),
              maxLines: 3, overflow: TextOverflow.ellipsis),
          if (isPending) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.touch_app_outlined, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Text('Tap to view full offer and respond in My Trips',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
