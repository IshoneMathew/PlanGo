import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/hotel_service.dart';
import '../services/trip_service.dart';
import '../data/tour_guides_data.dart';
import '../data/itinerary_data.dart';
import 'my_trips_screen.dart';

class ItineraryPreviewScreen extends StatefulWidget {
  final String destination;
  final int days;
  final double budget;
  final List<String> interests;
  final DateTime? startDate;

  const ItineraryPreviewScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.budget,
    required this.interests,
    this.startDate,
  });

  @override
  State<ItineraryPreviewScreen> createState() => _ItineraryPreviewScreenState();
}

class _ItineraryPreviewScreenState extends State<ItineraryPreviewScreen> {
  // ── State ────────────────────────────────────────────────────
  late List<DayItinerary> _itinerary;
  Map<int, List<Hotel>> _hotelsByDay = {};
  Map<int, bool> _loadingHotels = {};
  String _transportMode = 'car';
  TourGuide? _selectedGuide;
  bool _wantGuide = false;
  bool _booking = false;

  static const _transportModes = [
    {
      'id': 'car',
      'label': 'Private Car',
      'icon': Icons.directions_car_outlined,
      'price': 40
    },
    {
      'id': 'bus',
      'label': 'Bus',
      'icon': Icons.directions_bus_outlined,
      'price': 5
    },
    {'id': 'train', 'label': 'Train', 'icon': Icons.train_outlined, 'price': 8},
    {
      'id': 'tuktuk',
      'label': 'Tuk-tuk',
      'icon': Icons.electric_rickshaw_outlined,
      'price': 15
    },
  ];

  @override
  void initState() {
    super.initState();
    final plans = ItineraryData.getDayPlans(widget.destination, widget.days);
    _itinerary = List.generate(widget.days, (i) {
      final plan = plans[i];
      return DayItinerary(
        day: i + 1,
        activities: List<String>.from(plan['activities'] as List),
        lastStop: plan['stop'] as String,
        imageUrl: plan['image'] as String,
      );
    });
    if (widget.days > 1) _loadAllHotels();
  }

  Future<void> _loadAllHotels() async {
    for (final day in _itinerary) {
      if (day.day == _itinerary.last.day) continue; // no hotel on last day
      setState(() => _loadingHotels[day.day] = true);
      final perNight = (widget.budget / widget.days) * 0.45;
      final hotels = await HotelService.getHotels(
        city: day.lastStop,
        budgetPerNight: perNight,
        nights: 1,
      );
      if (mounted)
        setState(() {
          _hotelsByDay[day.day] = hotels;
          _loadingHotels[day.day] = false;
          if (hotels.isNotEmpty) day.selectedHotel = hotels.first;
        });
    }
  }

  // ── Cost calculation ─────────────────────────────────────────
  double get _hotelTotal => _itinerary
      .where((d) => d.selectedHotel != null)
      .fold(0.0, (sum, d) => sum + (d.selectedHotel!.pricePerNight));

  double get _transportCostPerDay =>
      (_transportModes.firstWhere((m) => m['id'] == _transportMode)['price']
              as int)
          .toDouble();

  double get _transportTotal => _transportCostPerDay * widget.days.toDouble();

  double get _guideTotal => _wantGuide && _selectedGuide != null
      ? _selectedGuide!.pricePerDay * widget.days
      : 0;

  double get _activitiesEstimate => 25.0 * widget.days;
  double get _foodEstimate => 20.0 * widget.days;

  double get _totalCost =>
      _hotelTotal +
      _transportTotal +
      _guideTotal +
      _activitiesEstimate +
      _foodEstimate;

  bool get _overBudget => _totalCost > widget.budget;
  double get _budgetDiff => (_totalCost - widget.budget).abs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _buildSummaryCard(),
                  if (_overBudget) _buildBudgetWarning(),
                  const SizedBox(height: 20),
                  _buildTransportSection(),
                  const SizedBox(height: 20),
                  ..._buildDayCards(),
                  const SizedBox(height: 20),
                  _buildTourGuideSection(),
                  const SizedBox(height: 20),
                  _buildCostBreakdown(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildBookButton(context),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        const Expanded(
            child: Center(
          child: Text('Your Itinerary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _overBudget
                  ? AppColors.red.withOpacity(0.1)
                  : AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(_overBudget ? '⚠️ Over budget' : '✓ In budget',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _overBudget ? AppColors.red : AppColors.green)),
        ),
      ]),
    );
  }

  // ── Summary card ──────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A1F36), Color(0xFF2D3561)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1A1F36).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.flight_takeoff, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(widget.destination,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const Spacer(),
          const Icon(Icons.auto_awesome, color: Colors.white30, size: 14),
          const SizedBox(width: 4),
          Text('AI Generated',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10, color: Colors.white30)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          _SumPill(Icons.calendar_today_outlined, '${widget.days} days',
              const Color(0xFF00C6FF)),
          _SumPill(Icons.attach_money, '\$${widget.budget.toInt()} budget',
              const Color(0xFF71B280)),
          _SumPill(
              Icons.receipt_long_outlined,
              '\$${_totalCost.toInt()} est. total',
              _overBudget ? AppColors.red : AppColors.accent),
        ]),
        const SizedBox(height: 14),
        ...(_itinerary.map((d) => _TimelineItem(
              name: 'Day ${d.day}: ${d.lastStop}',
              sub: d.activities.first,
              isFirst: d.day == 1,
              isLast: d.day == _itinerary.length,
              showLine: d.day < _itinerary.length,
            ))),
      ]),
    );
  }

  // ── Budget warning ────────────────────────────────────────────
  Widget _buildBudgetWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withOpacity(0.3))),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.red, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Over budget by \$${_budgetDiff.toInt()}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red)),
          const SizedBox(height: 2),
          Text(
              'Try selecting cheaper hotels below, a different transport mode, or skip the tour guide to bring costs down.',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.red.withOpacity(0.8),
                  height: 1.5)),
        ])),
      ]),
    );
  }

  // ── Transport section ────────────────────────────────────────
  Widget _buildTransportSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Transport Mode',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('Choose how you\'ll travel between stops',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 12),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3.0,
          children: _transportModes.map((m) {
            final sel = _transportMode == m['id'];
            return GestureDetector(
              onTap: () => setState(() => _transportMode = m['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? AppColors.primary : AppColors.divider),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 6)
                          ]
                        : null),
                child: Row(children: [
                  Icon(m['icon'] as IconData,
                      color: sel ? Colors.white : AppColors.textSecondary,
                      size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(m['label'] as String,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.white
                                    : AppColors.textPrimary)),
                        Text('\$${m['price']}/day',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: sel
                                    ? Colors.white70
                                    : AppColors.textSecondary)),
                      ])),
                ]),
              ),
            );
          }).toList()),
    ]);
  }

  // ── Day cards with hotel picker ───────────────────────────────
  List<Widget> _buildDayCards() {
    return _itinerary.map((day) {
      final isLastDay = day.day == _itinerary.length;
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Day image header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(children: [
              Image.network(day.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 100, color: Colors.grey.shade200)),
              Container(
                  height: 100,
                  decoration:
                      const BoxDecoration(gradient: AppColors.darkGradient)),
              Positioned(
                  bottom: 10,
                  left: 14,
                  right: 14,
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('Day ${day.day}',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white))),
                    const SizedBox(width: 8),
                    Text(day.lastStop,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ])),
            ]),
          ),
          // Activities
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...day.activities.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                  child: Text('${e.key + 1}',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(e.value,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500))),
                        ]),
                  )),

              // Hotel picker — only if not the last day
              if (!isLastDay && widget.days > 1) ...[
                const Divider(height: 20, color: AppColors.divider),
                Row(children: [
                  const Icon(Icons.hotel_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text("Tonight's Stay in ${day.lastStop}",
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 10),
                if (_loadingHotels[day.day] == true)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2)))
                else if ((_hotelsByDay[day.day] ?? []).isEmpty)
                  _noHotelsChip()
                else
                  _buildHotelPicker(day),
              ],
            ]),
          ),
        ]),
      );
    }).toList();
  }

  Widget _noHotelsChip() => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10)),
        child: Text(
            'No hotels found for this location — you can add one manually after booking.',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: AppColors.textSecondary)),
      );

  Widget _buildHotelPicker(DayItinerary day) {
    final hotels = _hotelsByDay[day.day] ?? [];
    final budgetPerNight = (widget.budget / widget.days) * 0.45;

    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length,
        itemBuilder: (_, i) {
          final hotel = hotels[i];
          final isSelected = day.selectedHotel?.id == hotel.id;
          final isOverBudget = hotel.pricePerNight > budgetPerNight * 1.1;

          return GestureDetector(
            onTap: () => setState(() => day.selectedHotel = hotel),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 200,
              margin: EdgeInsets.only(right: i < hotels.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isOverBudget
                              ? AppColors.warning.withOpacity(0.5)
                              : AppColors.divider,
                      width: isSelected ? 2 : 1),
                  color: isSelected ? AppColors.primaryLight : Colors.white,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 8)
                        ]
                      : null),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(13)),
                      child: Stack(children: [
                        Image.network(hotel.imageUrl,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.hotel,
                                    color: AppColors.grey))),
                        if (isOverBudget)
                          Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text('Over budget',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)))),
                        if (hotel.freeCancellation)
                          Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text('Free cancel',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)))),
                        if (isSelected)
                          Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 14))),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.name,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.star,
                                  color: AppColors.star, size: 11),
                              const SizedBox(width: 2),
                              Text('${hotel.rating}',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                              const Spacer(),
                              Text('\$${hotel.pricePerNight.toInt()}/night',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isOverBudget
                                          ? AppColors.warning
                                          : AppColors.primary)),
                            ]),
                          ]),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }

  // ── Tour guide section ────────────────────────────────────────
  Widget _buildTourGuideSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Tour Guide',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const Spacer(),
        Switch(
            value: _wantGuide,
            onChanged: (v) => setState(() => _wantGuide = v),
            activeColor: AppColors.primary),
      ]),
      Text('A certified local guide enhances your experience',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12, color: AppColors.textSecondary)),
      if (_wantGuide) ...[
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: TourGuidesData.availableGuides.length,
            itemBuilder: (_, i) {
              final guide = TourGuidesData.availableGuides[i];
              final isSelected = _selectedGuide?.id == guide.id;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedGuide = isSelected ? null : guide),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 175,
                  margin: EdgeInsets.only(
                      right: i < TourGuidesData.availableGuides.length - 1
                          ? 12
                          : 0),
                  decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 2 : 1),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(guide.photoUrl),
                                backgroundColor: Colors.grey.shade200),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(guide.name,
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary)),
                                  Row(children: [
                                    const Icon(Icons.star,
                                        color: AppColors.star, size: 11),
                                    const SizedBox(width: 2),
                                    Text('${guide.rating}',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                  ]),
                                ])),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 18),
                          ]),
                          const SizedBox(height: 8),
                          Text(guide.bio,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Wrap(
                              spacing: 4,
                              children: guide.specialties
                                  .take(2)
                                  .map((s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: AppColors.lightGrey,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text(s,
                                            style: GoogleFonts.spaceGrotesk(
                                                fontSize: 9,
                                                color:
                                                    AppColors.textSecondary)),
                                      ))
                                  .toList()),
                          const SizedBox(height: 6),
                          Text(
                              '\$${guide.pricePerDay}/day · ${guide.tours} tours',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ]);
  }

  // ── Cost breakdown ────────────────────────────────────────────
  Widget _buildCostBreakdown() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cost Breakdown',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        _CostRow('🏨 Hotels (${widget.days - 1} nights)', _hotelTotal),
        _CostRow(
            '🚗 Transport (${_transportModes.firstWhere((m) => m['id'] == _transportMode)['label']})',
            _transportTotal),
        _CostRow('🎭 Activities & entrance fees', _activitiesEstimate),
        _CostRow('🍛 Food & dining', _foodEstimate),
        if (_wantGuide && _selectedGuide != null)
          _CostRow('👤 Tour guide (${_selectedGuide!.name})', _guideTotal),
        const Divider(height: 20, color: AppColors.divider),
        Row(children: [
          Text('Estimated Total',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Text('\$${_totalCost.toInt()}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _overBudget ? AppColors.red : AppColors.primary)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text('Your budget',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          Text('\$${widget.budget.toInt()}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ]),
        if (_overBudget) ...[
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.red, size: 14),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                        'You are \$${_budgetDiff.toInt()} over your budget. Select cheaper hotels or a different transport mode.',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 11, color: AppColors.red, height: 1.4))),
              ])),
        ] else ...[
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.green, size: 14),
                const SizedBox(width: 6),
                Text(
                    'Great! You have \$${(widget.budget - _totalCost).toInt()} left for extras.',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: AppColors.green)),
              ])),
        ],
      ]),
    );
  }

  // ── Book button ───────────────────────────────────────────────
  Widget _buildBookButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))
      ]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_overBudget)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
                '⚠️ This trip exceeds your budget by \$${_budgetDiff.toInt()} — you can still book it.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500)),
          ),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _booking ? null : () => _bookTrip(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _overBudget ? AppColors.warning : AppColors.dark,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: _booking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Book This Sri Lanka Trip — \$${_totalCost.toInt()}',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.bookmark_border,
                    color: AppColors.primary, size: 22)),
          ),
        ]),
      ]),
    );
  }

  // ── Save trip to Firestore ────────────────────────────────────
  Future<void> _bookTrip(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() => _booking = true);

    final trip = BookedTrip(
      id: '',
      userId: uid,
      destination: widget.destination,
      days: widget.days,
      budget: widget.budget,
      totalCost: _totalCost,
      interests: widget.interests,
      itinerary: _itinerary,
      transportMode: _transportMode,
      tourGuide: _wantGuide ? _selectedGuide : null,
      createdAt: widget.startDate ?? DateTime.now(),
      status: 'upcoming',
    );

    try {
      await TripService.saveTrip(trip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('🎉 Trip booked and saved to My Trips!'),
            backgroundColor: AppColors.green));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyTripsScreen()),
          (r) => r.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _booking = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.red));
      }
    }
  }
}

// ── Helper widgets ────────────────────────────────────────────
class _SumPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SumPill(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      );
}

class _TimelineItem extends StatelessWidget {
  final String name, sub;
  final bool isFirst, isLast, showLine;
  const _TimelineItem(
      {required this.name,
      required this.sub,
      required this.isFirst,
      required this.isLast,
      required this.showLine});
  @override
  Widget build(BuildContext context) {
    final col = isFirst
        ? AppColors.green
        : isLast
            ? AppColors.accent
            : AppColors.primary;
    return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: col,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2))),
        if (showLine)
          Expanded(child: Container(width: 2, color: Colors.white24)),
      ]),
      const SizedBox(width: 10),
      Expanded(
          child: Padding(
        padding: EdgeInsets.only(bottom: showLine ? 12.0 : 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(sub,
              style:
                  GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      )),
    ]));
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;
  const _CostRow(this.label, this.amount);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13, color: AppColors.textSecondary))),
          Text('\$${amount.toInt()}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ]),
      );
} //build by gavesha
