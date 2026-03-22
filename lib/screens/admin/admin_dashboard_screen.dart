import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/trip_models.dart';
import '../../services/firebase_service.dart';
import '../../services/trip_service.dart';
import '../../data/drivers_data.dart';
import '../main_nav_screen.dart';
import '../profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool isHome;
  const AdminDashboardScreen({super.key, this.isHome = false});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          _buildTabs(),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              const _DestinationsTab(),
              const _BookingsTab(),
              const _StatsTab(),
            ]),
          ),
        ]),
      ),
      floatingActionButton: _tab.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDestinationSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add Destination',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            )
          : null,
      bottomNavigationBar: widget.isHome ? _buildAdminBottomBar(context) : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        if (!widget.isHome)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
          )
        else
          Container(width: 40, height: 40,
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Dashboard', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Manage destinations, bookings & content',
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shield_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text('Admin', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tab,
        onTap: (_) => setState(() {}), // refresh FAB visibility
        labelStyle: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 13),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Destinations'),
          Tab(text: 'Bookings'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAdminBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))]),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.home_outlined, color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 8),
                Text('Go to App', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ]),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.person_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Profile', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          )),
        ]),
      )),
    );
  }

  void _showAddDestinationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => const _DestinationFormSheet());
  }
}

// ═════════════════════════════════════════════════════════════════
// BOOKINGS TAB
// ═════════════════════════════════════════════════════════════════
class _BookingsTab extends StatefulWidget {
  const _BookingsTab();
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> with SingleTickerProviderStateMixin {
  late TabController _sub;

  @override
  void initState() { super.initState(); _sub = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _sub.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        child: TabBar(
          controller: _sub,
          labelStyle: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 12),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: const [Tab(text: 'New'), Tab(text: 'Confirmed'), Tab(text: 'All')],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<BookedTrip>>(
          stream: TripService.allTripsStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && (snap.data ?? []).isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
            }
            final all = snap.data ?? [];
            final newTrips = all.where((t) => t.status == 'upcoming').toList();
            final confirmed = all.where((t) => t.status == 'confirmed').toList();

            return TabBarView(controller: _sub, children: [
              _BookingList(trips: newTrips, label: 'New Bookings'),
              _BookingList(trips: confirmed, label: 'Confirmed'),
              _BookingList(trips: all, label: 'All Trips'),
            ]);
          },
        ),
      ),
    ]);
  }
}

class _BookingList extends StatelessWidget {
  final List<BookedTrip> trips;
  final String label;
  const _BookingList({required this.trips, required this.label});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.luggage_outlined, size: 60, color: AppColors.grey),
        const SizedBox(height: 16),
        Text('No $label', style: GoogleFonts.spaceGrotesk(fontSize: 16, color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: trips.length,
      itemBuilder: (_, i) => _AdminBookingCard(trip: trips[i]),
    );
  }
}

// ── Admin booking card ─────────────────────────────────────────────
class _AdminBookingCard extends StatelessWidget {
  final BookedTrip trip;
  const _AdminBookingCard({required this.trip});

  Color get _statusColor => switch (trip.status) {
    'confirmed'     => AppColors.green,
    'pending_offer' => AppColors.warning,
    'cancelled'     => AppColors.red,
    'completed'     => AppColors.grey,
    _               => AppColors.primary,
  };

  String get _statusLabel => switch (trip.status) {
    'upcoming'      => 'New Booking',
    'confirmed'     => 'Confirmed',
    'pending_offer' => 'Offer Sent',
    'cancelled'     => 'Cancelled',
    'completed'     => 'Completed',
    _               => trip.status,
  };

  @override
  Widget build(BuildContext context) {
    final date = trip.createdAt;
    final dateStr = '${date.day} ${_mo(date.month)} ${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header band
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: _statusColor.withOpacity(0.2)))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(trip.destination, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Booked $dateStr', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Guest info
            Row(children: [
              Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trip.userName?.isNotEmpty == true ? trip.userName! : 'Guest',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(trip.userEmail ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
              ])),
            ]),
            const SizedBox(height: 10),

            // Trip details chips
            Wrap(spacing: 8, runSpacing: 6, children: [
              _Chip(Icons.calendar_today_outlined, '${trip.days} days'),
              _Chip(Icons.attach_money, '\$${trip.totalCost.toInt()} total'),
              _Chip(_transportIcon(trip.transportMode), trip.transportMode),
              if (trip.assignedDriver != null)
                _Chip(Icons.directions_car, trip.assignedDriver!.name, color: AppColors.green),
            ]),

            // Pending offer notice
            if (trip.pendingOffer != null && trip.pendingOffer!.offerStatus == 'pending') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.schedule_send, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Offer sent — awaiting client response',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.warning))),
                ]),
              ),
            ],

            // Accepted offer notice
            if (trip.pendingOffer?.offerStatus == 'accepted') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.green, size: 16),
                  const SizedBox(width: 8),
                  Text('Client accepted the offer', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.green)),
                ]),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            if (trip.status == 'upcoming' || trip.status == 'pending_offer')
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOfferSheet(context, trip),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 9)),
                    child: Text('Send Offer', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmSheet(context, trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text('Confirm Trip', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ])
            else if (trip.status == 'confirmed')
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Trip Confirmed', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                    if (trip.assignedDriver != null)
                      Text('Driver: ${trip.assignedDriver!.name} · ${trip.assignedDriver!.phone}',
                          style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  void _showConfirmSheet(BuildContext context, BookedTrip trip) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmTripSheet(trip: trip));
  }

  void _showOfferSheet(BuildContext context, BookedTrip trip) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _SendOfferSheet(trip: trip));
  }

  IconData _transportIcon(String m) => switch (m) {
    'bus'    => Icons.directions_bus_outlined,
    'train'  => Icons.train_outlined,
    'tuktuk' => Icons.electric_rickshaw_outlined,
    _        => Icons.directions_car_outlined,
  };

  String _mo(int m) => ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

class _Chip extends StatelessWidget {
  final IconData icon; final String label; final Color? color;
  const _Chip(this.icon, this.label, {this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: (color ?? AppColors.primary).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color ?? AppColors.primary),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? AppColors.primary)),
    ]),
  );
}

// ── Confirm Trip Sheet ─────────────────────────────────────────────
class _ConfirmTripSheet extends StatefulWidget {
  final BookedTrip trip;
  const _ConfirmTripSheet({required this.trip});
  @override
  State<_ConfirmTripSheet> createState() => _ConfirmTripSheetState();
}

class _ConfirmTripSheetState extends State<_ConfirmTripSheet> {
  Driver? _selectedDriver;
  String _transport = 'car';
  bool _saving = false;

  static const _modes = [
    {'id': 'car',    'label': 'Private Car'},
    {'id': 'bus',    'label': 'Bus'},
    {'id': 'train',  'label': 'Train'},
    {'id': 'tuktuk', 'label': 'Tuk-tuk'},
  ];

  @override
  void initState() {
    super.initState();
    _transport = widget.trip.transportMode;
    _selectedDriver = widget.trip.assignedDriver;
  }

  Future<void> _confirm() async {
    if (_selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please assign a driver first'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _saving = true);
    await TripService.confirmTrip(tripId: widget.trip.id, driver: _selectedDriver!, transportMode: _transport);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✓ Trip confirmed and driver assigned!'), backgroundColor: AppColors.green));
    }
  }

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Confirm Trip',
    subtitle: widget.trip.destination,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('Transport Mode'),
      Wrap(spacing: 8, runSpacing: 8, children: _modes.map((m) {
        final sel = _transport == m['id'];
        return GestureDetector(
          onTap: () => setState(() => _transport = m['id']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10)),
            child: Text(m['label']!, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textPrimary)),
          ),
        );
      }).toList()),
      const SizedBox(height: 20),
      _SectionLabel('Assign Driver'),
      ...DriversData.availableDrivers.map((d) {
        final sel = _selectedDriver?.id == d.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedDriver = d),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 2 : 1)),
            child: Row(children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(d.photoUrl), backgroundColor: Colors.grey.shade200),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('${d.vehicleType} · ${d.vehiclePlate}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                Text(d.phone, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.primary)),
              ])),
              Row(children: [
                const Icon(Icons.star, color: AppColors.star, size: 13),
                const SizedBox(width: 3),
                Text('${d.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              if (sel) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: AppColors.primary, size: 20)],
            ]),
          ),
        );
      }),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _saving ? null : _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: _saving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Confirm & Assign Driver', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ]),
  );
}

// ── Send Offer Sheet ───────────────────────────────────────────────
class _SendOfferSheet extends StatefulWidget {
  final BookedTrip trip;
  const _SendOfferSheet({required this.trip});
  @override
  State<_SendOfferSheet> createState() => _SendOfferSheetState();
}

class _SendOfferSheetState extends State<_SendOfferSheet> {
  final _msgCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  Driver? _selectedDriver;
  String? _newTransport;
  bool _saving = false;
  bool _changePrice = false;
  bool _changeTransport = false;
  bool _assignDriver = false;

  static const _modes = [
    {'id': 'car', 'label': 'Private Car'},
    {'id': 'bus', 'label': 'Bus'},
    {'id': 'train', 'label': 'Train'},
    {'id': 'tuktuk', 'label': 'Tuk-tuk'},
  ];

  @override
  void initState() {
    super.initState();
    _priceCtrl.text = widget.trip.totalCost.toInt().toString();
  }

  @override
  void dispose() { _msgCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write a message to the client'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _saving = true);
    await TripService.sendOffer(
      tripId: widget.trip.id,
      message: _msgCtrl.text.trim(),
      newTotalCost: _changePrice ? double.tryParse(_priceCtrl.text) : null,
      newTransportMode: _changeTransport ? _newTransport : null,
      assignedDriver: _assignDriver ? _selectedDriver : null,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('📨 Offer sent to client!'), backgroundColor: AppColors.primary));
    }
  }

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Send Offer to Client',
    subtitle: widget.trip.destination,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('Message to Client *'),
      TextField(
        controller: _msgCtrl, maxLines: 3,
        style: GoogleFonts.spaceGrotesk(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'e.g. "We have reviewed your booking. We suggest a slight price change due to peak season rates…"',
          hintStyle: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.grey),
          contentPadding: const EdgeInsets.all(12)),
      ),
      const SizedBox(height: 16),

      // Price change toggle
      _ToggleRow('Change total price', _changePrice, (v) => setState(() => _changePrice = v)),
      if (_changePrice) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _priceCtrl, keyboardType: TextInputType.number,
          style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(prefixText: '\$  ', contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
        ),
        const SizedBox(height: 8),
        Text('Original: \$${widget.trip.totalCost.toInt()}',
            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
      ],
      const SizedBox(height: 12),

      // Transport change toggle
      _ToggleRow('Change transport mode', _changeTransport, (v) => setState(() => _changeTransport = v)),
      if (_changeTransport) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _modes.map((m) {
          final sel = (_newTransport ?? widget.trip.transportMode) == m['id'];
          return GestureDetector(
            onTap: () => setState(() => _newTransport = m['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10)),
              child: Text(m['label']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList()),
      ],
      const SizedBox(height: 12),

      // Driver assignment toggle
      _ToggleRow('Include driver assignment', _assignDriver, (v) => setState(() => _assignDriver = v)),
      if (_assignDriver) ...[
        const SizedBox(height: 8),
        ...DriversData.availableDrivers.map((d) {
          final sel = _selectedDriver?.id == d.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedDriver = d),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sel ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 2 : 1)),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundImage: NetworkImage(d.photoUrl), backgroundColor: Colors.grey.shade200),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${d.vehicleType} · ${d.vehiclePlate}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.textSecondary)),
                ])),
                if (sel) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              ]),
            ),
          );
        }),
      ],

      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _saving ? null : _send,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: _saving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Send Offer to Client', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ]),
  );
}

// ── Reusable sheet wrapper ─────────────────────────────────────────
class _Sheet extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _Sheet({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.88, maxChildSize: 0.97, minChildSize: 0.5,
    builder: (_, sc) => Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.grey)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(child: ListView(controller: sc, padding: const EdgeInsets.all(20), children: [child])),
      ]),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  );
}

class _ToggleRow extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool> onChanged;
  const _ToggleRow(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
  ]);
}

// ═════════════════════════════════════════════════════════════════
// DESTINATIONS TAB (unchanged)
// ═════════════════════════════════════════════════════════════════
class _DestinationsTab extends StatelessWidget {
  const _DestinationsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Destination>>(
      stream: FirebaseService.destinationsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final destinations = snap.data ?? [];
        if (destinations.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.place_outlined, size: 60, color: AppColors.grey),
            const SizedBox(height: 16),
            Text('No destinations yet', style: GoogleFonts.spaceGrotesk(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Tap + to add your first destination',
                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.grey)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: destinations.length,
          itemBuilder: (_, i) => _AdminDestCard(destination: destinations[i], index: i, total: destinations.length),
        );
      },
    );
  }
}

class _AdminDestCard extends StatelessWidget {
  final Destination destination; final int index, total;
  const _AdminDestCard({required this.destination, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(children: [
            Image.network(destination.imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 130, color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined, size: 40, color: AppColors.grey))),
            Container(height: 130, decoration: const BoxDecoration(gradient: AppColors.darkGradient)),
            Positioned(bottom: 10, left: 14, right: 14,
              child: Row(children: [
                Expanded(child: Text(destination.name,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.green.withOpacity(0.85), borderRadius: BorderRadius.circular(8)),
                    child: Text('Active', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(destination.location,
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary))),
              const Icon(Icons.star, size: 13, color: AppColors.star),
              const SizedBox(width: 3),
              Text('${destination.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Text('\$${destination.pricePerPerson.toInt()}/person',
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => _DestinationFormSheet(existing: destination)),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: Text('Edit', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, destination),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: Text('Delete', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Destination d) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Destination', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
      content: Text('Delete "${d.name}"? This cannot be undone.', style: GoogleFonts.spaceGrotesk()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.spaceGrotesk(color: AppColors.red, fontWeight: FontWeight.w600))),
      ],
    ));
    if (ok == true) {
      await FirebaseService.deleteDestination(d.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${d.name} deleted'), backgroundColor: AppColors.red));
    }
  }
}

// ═════════════════════════════════════════════════════════════════
// ANALYTICS TAB
// ═════════════════════════════════════════════════════════════════
class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('destinations').snapshots(),
      builder: (context, snap) {
        final destCount = snap.data?.docs.length ?? 0;
        return StreamBuilder<List<BookedTrip>>(
          stream: TripService.allTripsStream(),
          builder: (context, tripSnap) {
            final trips = tripSnap.data ?? [];
            final confirmed = trips.where((t) => t.status == 'confirmed').length;
            final pending = trips.where((t) => t.status == 'upcoming').length;
            final revenue = trips.where((t) => t.status == 'confirmed' || t.status == 'completed')
                .fold(0.0, (s, t) => s + t.totalCost);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _StatCard(icon: Icons.place, label: 'Total Destinations', value: '$destCount', color: AppColors.primary),
                const SizedBox(height: 12),
                _StatCard(icon: Icons.luggage_outlined, label: 'New Bookings', value: '$pending', color: AppColors.warning),
                const SizedBox(height: 12),
                _StatCard(icon: Icons.check_circle_outline, label: 'Confirmed Trips', value: '$confirmed', color: AppColors.green),
                const SizedBox(height: 12),
                _StatCard(icon: Icons.attach_money, label: 'Total Revenue', value: '\$${revenue.toInt()}', color: AppColors.accent),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Quick Actions', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ]),
                    const SizedBox(height: 10),
                    Text('• New bookings appear in the Bookings tab\n'
                        '• Tap "Confirm Trip" to assign a driver\n'
                        '• Tap "Send Offer" to propose changes\n'
                        '• Client accepts/declines in My Trips\n'
                        '• Changes sync to all users in real-time',
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.primary, height: 1.8)),
                  ]),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color; final String? subtitle;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
    child: Row(children: [
      Container(width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        if (subtitle != null) Text(subtitle!, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
      ])),
    ]),
  );
}

// ═════════════════════════════════════════════════════════════════
// DESTINATION FORM SHEET (add / edit)
// ═════════════════════════════════════════════════════════════════
class _DestinationFormSheet extends StatefulWidget {
  final Destination? existing;
  const _DestinationFormSheet({this.existing});
  @override
  State<_DestinationFormSheet> createState() => _DestinationFormSheetState();
}

class _DestinationFormSheetState extends State<_DestinationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _location, _province, _price, _rating, _desc, _imageUrl;
  List<String> _galleryUrls = [];
  bool _loading = false;
  String? _error;
  File? _pickedImage;
  final _picker = ImagePicker();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _name     = TextEditingController(text: d?.name ?? '');
    _location = TextEditingController(text: d?.location ?? '');
    _province = TextEditingController(text: d?.province ?? '');
    _price    = TextEditingController(text: d?.pricePerPerson.toInt().toString() ?? '');
    _rating   = TextEditingController(text: d?.rating.toString() ?? '4.5');
    _desc     = TextEditingController(text: d?.description ?? '');
    _imageUrl = TextEditingController(text: d?.imageUrl ?? '');
    _galleryUrls = List<String>.from(d?.galleryImages ?? []);
  }

  @override
  void dispose() {
    for (final c in [_name, _location, _province, _price, _rating, _desc, _imageUrl]) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xf != null) setState(() => _pickedImage = File(xf.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      String imgUrl = _imageUrl.text.trim();
      if (_pickedImage != null) {
        final tempId = _isEditing ? widget.existing!.id : 'new_${DateTime.now().millisecondsSinceEpoch}';
        imgUrl = await FirebaseService.uploadDestinationImage(_pickedImage!, tempId);
      }
      final data = {
        'name': _name.text.trim(), 'location': _location.text.trim(),
        'province': _province.text.trim(),
        'pricePerPerson': double.tryParse(_price.text) ?? 0.0,
        'rating': double.tryParse(_rating.text) ?? 4.5,
        'imageUrl': imgUrl, 'description': _desc.text.trim(),
        'galleryImages': _galleryUrls.where((u) => u.isNotEmpty).toList(),
        'travelers': widget.existing?.travelers ?? 0,
        'reviews': widget.existing?.reviews ?? 0,
        'isFavorite': widget.existing?.isFavorite ?? false,
        'isBookmarked': widget.existing?.isBookmarked ?? false,
      };
      if (_isEditing) {
        await FirebaseService.updateDestination(widget.existing!.id, data);
      } else {
        await FirebaseService.addDestination(data);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEditing ? 'Destination updated!' : 'Destination added!'),
            backgroundColor: AppColors.green));
      }
    } catch (e) {
      setState(() { _error = 'Failed to save: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92, maxChildSize: 0.97, minChildSize: 0.5,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(children: [
                Text(_isEditing ? 'Edit Destination' : 'Add Destination',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.grey)),
              ]),
            ),
            const Divider(height: 20),
            Expanded(child: ListView(controller: sc, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
              if (_error != null) ...[
                Container(padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.red))),
                const SizedBox(height: 12),
              ],
              _buildImagePicker(),
              const SizedBox(height: 20),
              _field('Destination Name', _name, required: true),
              _field('Location', _location, required: true),
              _field('Province', _province, required: true),
              _field('Price per Person (USD)', _price, keyboardType: TextInputType.number),
              _field('Rating', _rating, keyboardType: TextInputType.number),
              _field('Description', _desc, maxLines: 4, required: true),
              const SizedBox(height: 8),
              Text('Gallery Images', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ..._galleryUrls.asMap().entries.map((e) => _galleryField(e.key)),
              TextButton.icon(
                onPressed: () => setState(() => _galleryUrls.add('')),
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: Text('Add Gallery URL', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark, minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Save Changes' : 'Add Destination',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Cover Image', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      TextFormField(controller: _imageUrl,
          style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: 'Paste image URL',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('OR', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey))),
        Expanded(child: Divider(color: AppColors.divider)),
      ]),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: _pickedImage != null ? 160 : 80,
          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider)),
          child: _pickedImage != null
              ? ClipRRect(borderRadius: BorderRadius.circular(13),
                  child: Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity))
              : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.upload_rounded, color: AppColors.grey, size: 28),
                  const SizedBox(height: 4),
                  Text('Upload from Device', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.grey)),
                ])),
        ),
      ),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textPrimary),
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
      ]),
    );
  }

  Widget _galleryField(int index) {
    final ctrl = TextEditingController(text: _galleryUrls[index]);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: TextField(controller: ctrl, onChanged: (v) => _galleryUrls[index] = v,
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: 'Gallery image URL ${index + 1}',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
        const SizedBox(width: 8),
        GestureDetector(onTap: () => setState(() => _galleryUrls.removeAt(index)),
            child: Container(width: 32, height: 32,
                decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close, color: AppColors.red, size: 14))),
      ]),
    );
  }
}
