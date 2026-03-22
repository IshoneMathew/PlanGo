import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import 'my_trips_screen.dart';

String _monthName(int m) => const [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
][m];

String _shortMonth(int m) => const [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
][m];

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    // Start week on Sunday
    _currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
  }

  List<DateTime> get _weekDates =>
      List.generate(7, (i) => _currentWeekStart.add(Duration(days: i)));

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<BookedTrip>>(
              stream: TripService.userTripsStream(),
              builder: (context, snap) {
                final trips = (snap.data ?? [])
                    .where((t) => t.status == 'upcoming' || t.status == 'confirmed')
                    .toList();

                // Build a set of dates that have trips for dot indicators
                final tripDates = <String>{};
                for (final t in trips) {
                  for (int d = 0; d < t.days; d++) {
                    final date = t.createdAt.add(Duration(days: d));
                    tripDates.add('${date.year}-${date.month}-${date.day}');
                  }
                }

                // Trips for selected date
                final selectedTrips = trips.where((t) {
                  final start = t.createdAt;
                  final end = start.add(Duration(days: t.days));
                  return !_selectedDate.isBefore(start) && _selectedDate.isBefore(end);
                }).toList();

                return SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildCalendarCard(tripDates),
                    _buildScheduleSection(selectedTrips, trips),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        const Expanded(child: Center(child: Text('Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
        // Today button
        GestureDetector(
          onTap: () {
            final now = DateTime.now();
            setState(() {
              _selectedDate = now;
              _currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Text('Today', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ),
      ]),
    );
  }

  Widget _buildCalendarCard(Set<String> tripDates) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)]),
      child: Column(children: [
        // Month navigation
        Row(children: [
          Text('${_monthName(_selectedDate.month)} ${_selectedDate.year}',
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7))),
            child: const Icon(Icons.chevron_left, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _currentWeekStart = _currentWeekStart.add(const Duration(days: 7))),
            child: const Icon(Icons.chevron_right, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 16),
        // Day labels
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((d) => SizedBox(width: 36,
                child: Text(d, textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)))).toList()),
        const SizedBox(height: 10),
        // Date cells
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDates.map((date) {
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              final hasTrip = tripDates.contains('${date.year}-${date.month}-${date.day}');

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 36, height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.dark : Colors.transparent,
                    borderRadius: BorderRadius.circular(14)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${date.day}', style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? Colors.white
                          : isToday ? AppColors.primary
                          : AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    // Trip dot indicator
                    Container(width: 5, height: 5, decoration: BoxDecoration(
                      color: hasTrip
                          ? (isSelected ? Colors.white : AppColors.accent)
                          : Colors.transparent,
                      shape: BoxShape.circle)),
                  ]),
                ),
              );
            }).toList()),
      ]),
    );
  }

  Widget _buildScheduleSection(List<BookedTrip> selectedTrips, List<BookedTrip> allTrips) {
    final dateLabel = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month
        ? 'Today'
        : '${_selectedDate.day} ${_shortMonth(_selectedDate.month)}';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(children: [
          Text('$dateLabel\'s Schedule',
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen())),
            child: Text('View all', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
        ]),
      ),

      if (selectedTrips.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: Row(children: [
              Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.calendar_today_outlined, color: AppColors.grey, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('No trips on this day', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text('Book a trip to see it here', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.grey)),
              ])),
            ]),
          ),
        )
      else
        ...selectedTrips.map((t) => _TripScheduleCard(trip: t, selectedDate: _selectedDate)),

      // Upcoming trips section
      if (allTrips.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text('Upcoming', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        ...allTrips.take(3).map((t) => _UpcomingTripRow(trip: t)),
      ],
      const SizedBox(height: 32),
    ]);
  }
}

// ── Trip card for selected date ────────────────────────────────────
class _TripScheduleCard extends StatelessWidget {
  final BookedTrip trip;
  final DateTime selectedDate;
  const _TripScheduleCard({required this.trip, required this.selectedDate});

  static const _images = [
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
    return _images[trip.id.hashCode.abs() % _images.length];
  }

  // Which day of the trip is this?
  int get _dayNumber {
    final diff = selectedDate.difference(
        DateTime(trip.createdAt.year, trip.createdAt.month, trip.createdAt.day)).inDays;
    return diff + 1;
  }

  @override
  Widget build(BuildContext context) {
    final dayPlan = _dayNumber <= trip.itinerary.length
        ? trip.itinerary[_dayNumber - 1]
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          child: Image.network(_image, width: 80, height: 90, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 80, height: 90, color: Colors.grey.shade200))),
        const SizedBox(width: 14),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: trip.status == 'confirmed' ? AppColors.green : AppColors.primary,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Day $_dayNumber of ${trip.days}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
            ]),
            const SizedBox(height: 5),
            Text(trip.destination, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (dayPlan != null) ...[
              const SizedBox(height: 3),
              Text(dayPlan.activities.first,
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
              const SizedBox(width: 2),
              Text(dayPlan?.lastStop ?? trip.destination,
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
            ]),
          ]),
        )),
        const Padding(padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.chevron_right, color: AppColors.grey, size: 20)),
      ]),
    );
  }
}

// ── Upcoming trip compact row ──────────────────────────────────────
class _UpcomingTripRow extends StatelessWidget {
  final BookedTrip trip;
  const _UpcomingTripRow({required this.trip});

  @override
  Widget build(BuildContext context) {
    final start = trip.createdAt;
    final end = start.add(Duration(days: trip.days));
    final dateStr = '${start.day} ${_shortMonth(start.month)} → ${end.day} ${_shortMonth(end.month)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(
                color: trip.status == 'confirmed' ? AppColors.green.withOpacity(0.1) : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.flight_takeoff_outlined,
                color: trip.status == 'confirmed' ? AppColors.green : AppColors.primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(trip.destination, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(dateStr, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Text('${trip.days}d', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }
}
