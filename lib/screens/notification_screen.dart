import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import 'my_trips_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          TabBar(
            controller: _tab,
            labelStyle: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 14),
            labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary, indicatorWeight: 2.5,
            tabs: const [Tab(text: 'Trips'), Tab(text: 'System')],
          ),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              _TripNotifications(),
              _SystemNotifications(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.maybePop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary))),
        const Expanded(child: Center(child: Text('Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
        const SizedBox(width: 40),
      ]),
    );
  }
}

// ── Trip Notifications (real data from Firestore) ─────────────────
class _TripNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookedTrip>>(
      stream: TripService.userTripsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
        }
        final trips = snap.data ?? [];

        // Build notification events from trips
        final notifications = <_TripNotif>[];

        for (final t in trips) {
          // Pending offer notification
          if (t.pendingOffer != null && t.pendingOffer!.offerStatus == 'pending') {
            notifications.add(_TripNotif(
              icon: Icons.local_offer_outlined,
              color: AppColors.warning,
              title: 'New offer for ${t.destination}',
              body: t.pendingOffer!.message,
              time: t.pendingOffer!.sentAt,
              trip: t,
              isOffer: true,
            ));
          }
          // Confirmed notification
          if (t.status == 'confirmed') {
            notifications.add(_TripNotif(
              icon: Icons.check_circle_outline,
              color: AppColors.green,
              title: '${t.destination} confirmed!',
              body: t.assignedDriver != null
                  ? 'Your driver ${t.assignedDriver!.name} has been assigned.'
                  : 'Your trip has been confirmed by admin.',
              time: t.createdAt,
              trip: t,
            ));
          }
          // Upcoming reminder
          if (t.status == 'upcoming' || t.status == 'confirmed') {
            final daysUntil = t.createdAt.difference(DateTime.now()).inDays;
            if (daysUntil > 0 && daysUntil <= 7) {
              notifications.add(_TripNotif(
                icon: Icons.notifications_active_outlined,
                color: AppColors.primary,
                title: 'Trip in $daysUntil day${daysUntil > 1 ? "s" : ""}!',
                body: '${t.destination} is coming up soon. Check your itinerary.',
                time: DateTime.now(),
                trip: t,
              ));
            }
          }
        }

        notifications.sort((a, b) => b.time.compareTo(a.time));

        if (notifications.isEmpty) {
          return _EmptyState(
            icon: Icons.notifications_none_outlined,
            title: 'No notifications yet',
            subtitle: 'Trip updates and offers will appear here',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _NotifCard(notif: notifications[i]),
        );
      },
    );
  }
}

// ── System notifications (empty state) ────────────────────────────
class _SystemNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _EmptyState(
    icon: Icons.campaign_outlined,
    title: 'No system notifications',
    subtitle: 'App updates and announcements will appear here',
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 64, color: AppColors.grey),
    const SizedBox(height: 16),
    Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    const SizedBox(height: 6),
    Text(subtitle, textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.grey)),
  ]));
}

class _TripNotif {
  final IconData icon; final Color color;
  final String title, body; final DateTime time;
  final BookedTrip trip; final bool isOffer;
  const _TripNotif({required this.icon, required this.color, required this.title,
      required this.body, required this.time, required this.trip, this.isOffer = false});
}

class _NotifCard extends StatelessWidget {
  final _TripNotif notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(notif.time);
    final timeStr = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : '${diff.inDays}d ago';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            border: notif.isOffer ? Border.all(color: AppColors.warning.withOpacity(0.3)) : null),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 42, height: 42,
              decoration: BoxDecoration(color: notif.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(notif.icon, color: notif.color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.title,
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              Text(timeStr, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
            ]),
            const SizedBox(height: 4),
            Text(notif.body, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            if (notif.isOffer) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('Tap to view & respond',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning))),
            ],
          ])),
        ]),
      ),
    );
  }
}//done by nesandu
