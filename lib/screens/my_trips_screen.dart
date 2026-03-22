import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import 'trip_edit_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});
  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: StreamBuilder<List<BookedTrip>>(
                stream: TripService.userTripsStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2));
                  }
                  final all = snap.data ?? [];
                  final upcoming = all
                      .where((t) => t.status == 'upcoming')
                      .toList();
                  final past = all
                      .where((t) =>
                          t.status == 'completed' ||
                          t.status == 'cancelled')
                      .toList();
                  final saved = all
                      .where((t) => t.status == 'saved')
                      .toList();

                  return TabBarView(
                    controller: _tab,
                    children: [
                      _TripList(trips: upcoming, emptyIcon: Icons.flight_takeoff_outlined, emptyMsg: 'No upcoming trips yet', emptyHint: 'Plan your next Sri Lanka adventure!'),
                      _TripList(trips: past, emptyIcon: Icons.history, emptyMsg: 'No past trips yet', emptyHint: 'Your completed trips will appear here'),
                      _TripList(trips: saved, emptyIcon: Icons.bookmark_border, emptyMsg: 'No saved trips', emptyHint: 'Save itineraries to review later'),
                    ],
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
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('My Trips',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tab,
      labelStyle:
          GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 14),
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
      tabs: const [
        Tab(text: 'Upcoming'),
        Tab(text: 'Past'),
        Tab(text: 'Saved')
      ],
    );
  }
}

// ── Trip list ──────────────────────────────────────────────────────
class _TripList extends StatelessWidget {
  final List<BookedTrip> trips;
  final IconData emptyIcon;
  final String emptyMsg, emptyHint;

  const _TripList({
    required this.trips,
    required this.emptyIcon,
    required this.emptyMsg,
    required this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(emptyIcon, size: 60, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(emptyMsg,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(emptyHint,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppColors.grey)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: trips.length,
      itemBuilder: (_, i) => _TripCard(trip: trips[i]),
    );
  }
}

// ── Trip card ──────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final BookedTrip trip;

  const _TripCard({required this.trip});

  static const _dayImages = [
    'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
    'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
    'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80',
  ];

  String get _image {
    if (trip.itinerary.isNotEmpty && trip.itinerary.first.imageUrl.isNotEmpty) {
      return trip.itinerary.first.imageUrl;
    }
    return _dayImages[trip.id.hashCode.abs() % _dayImages.length];
  }

  Color get _statusColor => switch (trip.status) {
        'upcoming'      => AppColors.primary,
        'confirmed'     => AppColors.green,
        'pending_offer' => AppColors.warning,
        'cancelled'     => AppColors.red,
        'completed'     => AppColors.grey,
        _               => AppColors.primary,
      };

  String get _statusLabel => switch (trip.status) {
        'upcoming'      => 'Pending Confirmation',
        'confirmed'     => 'Confirmed',
        'pending_offer' => '📨 Offer from Admin',
        'cancelled'     => 'Cancelled',
        'completed'     => 'Completed',
        _               => trip.status,
      };

  String get _transportLabel => switch (trip.transportMode) {
        'car' => '🚗 Private Car',
        'bus' => '🚌 Bus',
        'train' => '🚂 Train',
        'tuktuk' => '🛺 Tuk-tuk',
        _ => trip.transportMode,
      };

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${trip.createdAt.day} ${_monthName(trip.createdAt.month)} ${trip.createdAt.year}';
    final isUpcoming = trip.status == 'upcoming';

    // Build hotel summary
    final hotelsSelected = trip.itinerary
        .where((d) => d.selectedHotel != null)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image + status
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(_image,
                height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 160, color: Colors.grey.shade200)),
          ),
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _statusColor, borderRadius: BorderRadius.circular(20)),
              child: Text(_statusLabel,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: 12, left: 14, right: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.destination,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text('Booked $dateStr',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11, color: Colors.white70)),
                        ]),
                      ]),
                ),
                Text('\$${trip.totalCost.toInt()}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ],
            ),
          ),
        ]),

        // Trip details
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Quick stats row
            Row(children: [
              _StatChip(Icons.nights_stay_outlined, '${trip.days} days'),
              const SizedBox(width: 8),
              _StatChip(Icons.hotel_outlined, '$hotelsSelected hotel${hotelsSelected != 1 ? 's' : ''}'),
              const SizedBox(width: 8),
              Expanded(child: _StatChip(Icons.directions_car_outlined, _transportLabel)),
            ]),

            // Tour guide if any
            if (trip.tourGuide != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('Guide: ${trip.tourGuide!.name}',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ]),
              ),
            ],

            // Budget vs actual
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _BudgetBar(budget: trip.budget, total: trip.totalCost)),
            ]),

            // Driver assigned info
            if (trip.assignedDriver != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.directions_car, color: AppColors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Driver Assigned', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green)),
                    Text('${trip.assignedDriver!.name} · ${trip.assignedDriver!.phone}',
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                    Text('${trip.assignedDriver!.vehicleType} (${trip.assignedDriver!.vehiclePlate})',
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
            ],

            // Pending offer from admin
            if (trip.pendingOffer != null && trip.pendingOffer!.offerStatus == 'pending') ...[
              const SizedBox(height: 10),
              _OfferBanner(trip: trip),
            ],

            const SizedBox(height: 12),
            if (isUpcoming) ...[
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TripEditScreen(trip: trip))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.edit_outlined, size: 15),
                      const SizedBox(width: 6),
                      Text('Edit Trip', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Cancel', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning)),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withOpacity(0.3))),
                    child: const Icon(Icons.delete_outline, color: AppColors.red, size: 18)),
                ),
              ]),
            ] else ...[
              // Past/cancelled trips — only Delete
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withOpacity(0.2))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.delete_outline, color: AppColors.red, size: 15),
                      const SizedBox(width: 6),
                      Text('Delete', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red)),
                    ]),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Trip',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to cancel your trip to ${trip.destination}?',
            style: GoogleFonts.spaceGrotesk()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Trip')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cancel Trip',
                style: GoogleFonts.spaceGrotesk(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await TripService.cancelTrip(trip.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Trip cancelled'),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Trip', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
            'Permanently delete your trip to \${trip.destination}? This cannot be undone.',
            style: GoogleFonts.spaceGrotesk()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.spaceGrotesk(color: AppColors.red, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (ok == true) {
      await TripService.deleteTrip(trip.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Trip deleted'), backgroundColor: AppColors.red));
      }
    }
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis),
        ),
      ]);
}

class _BudgetBar extends StatelessWidget {
  final double budget, total;
  const _BudgetBar({required this.budget, required this.total});

  @override
  Widget build(BuildContext context) {
    final over = total > budget;
    final ratio = (total / (budget == 0 ? 1 : budget)).clamp(0.0, 1.5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Budget', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
        const Spacer(),
        Text(over ? '⚠️ Over by \$${(total - budget).toInt()}' : '✓ \$${(budget - total).toInt()} under',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: over ? AppColors.warning : AppColors.green)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(children: [
          Container(height: 6, color: AppColors.lightGrey),
          FractionallySizedBox(
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: over ? AppColors.warning : AppColors.green,
                  borderRadius: BorderRadius.circular(4),
                )),
          ),
        ]),
      ),
      const SizedBox(height: 3),
      Row(children: [
        Text('\$0', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.grey)),
        const Spacer(),
        Text('\$${budget.toInt()} budget', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.grey)),
      ]),
    ]);
  }
}

// ── Offer Banner Widget ────────────────────────────────────────────
class _OfferBanner extends StatefulWidget {
  final BookedTrip trip;
  const _OfferBanner({required this.trip});
  @override
  State<_OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<_OfferBanner> {
  bool _loading = false;

  Future<void> _accept() async {
    setState(() => _loading = true);
    await TripService.acceptOffer(widget.trip.id);
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✓ Offer accepted! Trip confirmed.'), backgroundColor: AppColors.green));
    }
  }

  Future<void> _decline() async {
    setState(() => _loading = true);
    await TripService.declineOffer(widget.trip.id);
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Offer declined. Original booking kept.'), backgroundColor: AppColors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.trip.pendingOffer!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.06), AppColors.accent.withOpacity(0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New Offer from Admin', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text('Tap to accept or decline', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('Action Required', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.warning))),
        ]),
        const SizedBox(height: 10),

        // Message
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text('"${offer.message}"',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textPrimary, height: 1.5, fontStyle: FontStyle.italic)),
        ),

        // Changes summary
        if (offer.newTotalCost != null || offer.newTransportMode != null || offer.assignedDriver != null) ...[
          const SizedBox(height: 10),
          Text('Proposed Changes:', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          if (offer.newTotalCost != null)
            _ChangeRow('💰 New price', '\$${offer.newTotalCost!.toInt()} (was \$${widget.trip.totalCost.toInt()})'),
          if (offer.newTransportMode != null)
            _ChangeRow('🚗 Transport', offer.newTransportMode!),
          if (offer.assignedDriver != null)
            _ChangeRow('👤 Driver', '${offer.assignedDriver!.name} · ${offer.assignedDriver!.vehicleType}'),
        ],

        const SizedBox(height: 14),

        // Accept / Decline
        if (_loading)
          const Center(child: SizedBox(height: 20, width: 20,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
        else
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _accept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green, minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Accept Offer', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _decline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10)),
                child: Text('Decline', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red)),
              ),
            ),
          ]),
      ]),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final String label, value;
  const _ChangeRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text('$label: ', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
      Expanded(child: Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
    ]),
  );
}
