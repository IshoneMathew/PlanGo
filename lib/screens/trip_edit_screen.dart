import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import '../services/hotel_service.dart';
import '../data/tour_guides_data.dart';

class TripEditScreen extends StatefulWidget {
  final BookedTrip trip;
  const TripEditScreen({super.key, required this.trip});
  @override
  State<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends State<TripEditScreen> {
  late String _transportMode;
  late List<DayItinerary> _itinerary;
  bool _saving = false;
  Map<int, List<Hotel>> _hotelsByDay = {};
  Map<int, bool> _loadingHotels = {};

  static const _transportModes = [
    {'id': 'car',    'label': 'Private Car', 'icon': Icons.directions_car_outlined,    'price': 40},
    {'id': 'bus',    'label': 'Bus',         'icon': Icons.directions_bus_outlined,     'price': 5},
    {'id': 'train',  'label': 'Train',       'icon': Icons.train_outlined,             'price': 8},
    {'id': 'tuktuk', 'label': 'Tuk-tuk',    'icon': Icons.electric_rickshaw_outlined, 'price': 15},
  ];

  @override
  void initState() {
    super.initState();
    _transportMode = widget.trip.transportMode;
    _itinerary = List.from(widget.trip.itinerary);
    _loadHotelsForAllDays();
  }

  Future<void> _loadHotelsForAllDays() async {
    final perNight = (widget.trip.budget / widget.trip.days) * 0.45;
    for (final day in _itinerary) {
      if (day.day == _itinerary.length) continue;
      setState(() => _loadingHotels[day.day] = true);
      final hotels = await HotelService.getHotels(
        city: day.lastStop,
        budgetPerNight: perNight,
        nights: 1,
      );
      if (mounted) setState(() {
        _hotelsByDay[day.day] = hotels;
        _loadingHotels[day.day] = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      // Save transport mode
      await TripService.updateTransport(widget.trip.id, _transportMode);
      // Save hotel changes for each day
      for (final day in _itinerary) {
        if (day.selectedHotel != null) {
          await TripService.updateDayHotel(widget.trip.id, day.day, day.selectedHotel!);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✓ Trip updated successfully!'),
          backgroundColor: AppColors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _buildTripSummaryBanner(),
                const SizedBox(height: 20),
                _buildTransportSection(),
                const SizedBox(height: 20),
                _buildHotelSection(),
                const SizedBox(height: 20),
                _buildGuideSection(),
              ],
            ),
          ),
          _buildSaveBar(context),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edit Trip', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(widget.trip.destination, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: Text('${widget.trip.days} days', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildTripSummaryBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2))),
      child: Row(children: [
        const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'You can change transport and hotels with free cancellation. Other trip details are fixed after booking.',
          style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.primary, height: 1.5))),
      ]),
    );
  }

  Widget _buildTransportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text('Transport Mode', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.2,
          children: _transportModes.map((m) {
            final sel = _transportMode == m['id'];
            return GestureDetector(
              onTap: () => setState(() => _transportMode = m['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.divider)),
                child: Row(children: [
                  Icon(m['icon'] as IconData, color: sel ? Colors.white : AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(m['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textPrimary)),
                    Text('\$${m['price']}/day', style: GoogleFonts.spaceGrotesk(fontSize: 9,
                        color: sel ? Colors.white70 : AppColors.textSecondary)),
                  ])),
                ]),
              ),
            );
          }).toList()),
      ]),
    );
  }

  Widget _buildHotelSection() {
    final nights = widget.trip.days - 1;
    if (nights <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.hotel_outlined, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hotels', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('Only hotels with free cancellation can be changed',
                style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
          ])),
        ]),
        const SizedBox(height: 14),
        ..._itinerary.where((d) => d.day < _itinerary.length).map((day) => _buildDayHotelRow(day)),
      ]),
    );
  }

  Widget _buildDayHotelRow(DayItinerary day) {
    final hotels = _hotelsByDay[day.day] ?? [];
    final loading = _loadingHotels[day.day] == true;
    final current = day.selectedHotel;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text('${day.day}',
                style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 8),
          Text('Night in ${day.lastStop}',
              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (current != null) ...[
            const Spacer(),
            Text('\$${current.pricePerNight.toInt()}/night',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ]),
      ),

      // Current hotel selected
      if (current != null) Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3))),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(8),
              child: Image.network(current.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade200))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(current.name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(children: [
              const Icon(Icons.star, color: AppColors.star, size: 12),
              const SizedBox(width: 3),
              Text('${current.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              if (current.freeCancellation)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text('Free Cancel', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green))),
            ]),
          ])),
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ]),
      ),

      // Alternative hotels (only free cancellation ones can replace)
      if (loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
      else if (hotels.isNotEmpty)
        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length,
            itemBuilder: (_, i) {
              final hotel = hotels[i];
              final isCurrent = current?.id == hotel.id;
              final canSelect = hotel.freeCancellation || isCurrent;

              return Opacity(
                opacity: canSelect ? 1.0 : 0.45,
                child: GestureDetector(
                  onTap: canSelect ? () => setState(() => day.selectedHotel = hotel) : () => _showNoCancelInfo(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 180,
                    margin: EdgeInsets.only(right: i < hotels.length - 1 ? 10 : 0, bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isCurrent ? AppColors.primary : AppColors.divider, width: isCurrent ? 2 : 1),
                      color: isCurrent ? AppColors.primaryLight : Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: Stack(children: [
                          Image.network(hotel.imageUrl, height: 75, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 75, color: Colors.grey.shade200)),
                          if (!hotel.freeCancellation)
                            Positioned(top: 4, right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                child: Text('No free cancel',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.white)))),
                          if (hotel.freeCancellation)
                            Positioned(top: 4, left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(4)),
                                child: Text('Free cancel',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)))),
                          if (isCurrent)
                            const Positioned(bottom: 4, right: 4,
                              child: Icon(Icons.check_circle, color: AppColors.primary, size: 18)),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(hotel.name,
                              style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.star, color: AppColors.star, size: 11),
                            const SizedBox(width: 2),
                            Text('${hotel.rating}', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.textSecondary)),
                            const Spacer(),
                            Text('\$${hotel.pricePerNight.toInt()}/n',
                                style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      const Divider(height: 20, color: AppColors.divider),
    ]);
  }

  Widget _buildGuideSection() {
    final guideMap = widget.trip.tourGuide;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text('Tour Guide', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 14),

        if (guideMap != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Row(children: [
              CircleAvatar(radius: 22,
                  backgroundImage: NetworkImage(guideMap!.photoUrl),
                  backgroundColor: Colors.grey.shade200),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(guideMap!.name, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('\$${guideMap!.pricePerDay.toInt()}/day × ${widget.trip.days} days = \$${(guideMap!.pricePerDay * widget.trip.days).toInt()}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            ]),
          )
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No guide booked. Browse available guides below:',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: TourGuidesData.availableGuides.length,
                itemBuilder: (_, i) {
                  final g = TourGuidesData.availableGuides[i];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: i < TourGuidesData.availableGuides.length - 1 ? 12 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(g.photoUrl), backgroundColor: Colors.grey.shade200),
                        const SizedBox(width: 8),
                        Expanded(child: Text(g.name, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            maxLines: 2)),
                      ]),
                      const SizedBox(height: 6),
                      Text(g.bio, style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.textSecondary, height: 1.4),
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text('\$${g.pricePerDay}/day',
                          style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('Contact admin to add guide to your trip',
                          style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.grey)),
                    ]),
                  );
                },
              ),
            ),
          ]),
      ]),
    );
  }

  Widget _buildSaveBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))]),
      child: ElevatedButton(
        onPressed: _saving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _saving
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Save Changes',
                style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  void _showNoCancelInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('This hotel does not offer free cancellation and cannot be changed after booking.'),
      backgroundColor: AppColors.warning,
      duration: Duration(seconds: 3),
    ));
  }
}
