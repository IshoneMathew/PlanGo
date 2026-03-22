import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'itinerary_preview_screen.dart';

class PlannerWizardScreen extends StatefulWidget {
  const PlannerWizardScreen({super.key});
  @override
  State<PlannerWizardScreen> createState() => _PlannerWizardScreenState();
}

class _PlannerWizardScreenState extends State<PlannerWizardScreen> {
  int _step = 0;
  static const int _totalSteps = 4;

  String _destination = 'Sigiriya';
  int  _days   = 5;
  double _budget = 300;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  bool _useCustomBudget = false;
  final _customBudgetCtrl = TextEditingController();
  final Set<String> _interests = {'Culture'};

  final List<String> _destinations = [
    'Sigiriya','Kandy','Galle','Ella','Mirissa',
    'Arugam Bay','Yala','Nuwara Eliya','Trincomalee','Jaffna',
    'Anuradhapura','Dambulla','Unawatuna','Hikkaduwa','Colombo',
    'Bentota','Polonnaruwa','Negombo','Pinnawala','Horton Plains',
  ];

  final List<String> _allInterests = [
    '🏖️ Beaches','🏛️ Culture','🌿 Nature','🧗 Adventure',
    '🍜 Food','📸 Photography','🛍️ Shopping','🧘 Wellness',
    '🏨 Luxury','💰 Budget','👨‍👩‍👧 Family','🌙 Nightlife',
  ];

  @override
  void dispose() { _customBudgetCtrl.dispose(); super.dispose(); }

  double get _effectiveBudget {
    if (_useCustomBudget) {
      return double.tryParse(_customBudgetCtrl.text) ?? _budget;
    }
    return _budget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final titles = ['Where?', 'How long?', 'Budget?', 'Interests?'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => _step == 0 ? Navigator.pop(context) : setState(() => _step--),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        Expanded(child: Center(
          child: Text(titles[_step],
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        )),
        Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('${_step + 1}/$_totalSteps',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)))),
      ]),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(_totalSteps, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i <= _step ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(2)),
          ),
        )),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildDestinationStep();
      case 1: return _buildDurationStep();
      case 2: return _buildBudgetStep();
      case 3: return _buildInterestsStep();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Destination ─────────────────────────────────────
  Widget _buildDestinationStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Where in Sri Lanka?',
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Pick your dream destination', style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 24),
      Wrap(spacing: 10, runSpacing: 10,
        children: _destinations.map((d) {
          final sel = d == _destination;
          return GestureDetector(
            onTap: () => setState(() => _destination = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider),
                boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
              ),
              child: Text(d, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      Text('Or type any Sri Lanka city', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      TextField(
        onChanged: (v) { if (v.isNotEmpty) setState(() => _destination = v); },
        decoration: const InputDecoration(
          hintText: 'e.g. Bentota, Polonnaruwa…',
          prefixIcon: Icon(Icons.search, color: AppColors.grey, size: 20)),
      ),
    ]);
  }

  // ── Step 2: Duration ─────────────────────────────────────────
  Widget _buildDurationStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How many days?',
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Choose your trip duration', style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 40),
      Center(child: Column(children: [
        Text('$_days', style: GoogleFonts.spaceGrotesk(fontSize: 80, fontWeight: FontWeight.w800, color: AppColors.primary)),
        Text(_days == 1 ? 'day' : 'days', style: GoogleFonts.spaceGrotesk(fontSize: 18, color: AppColors.textSecondary)),
      ])),
      const SizedBox(height: 28),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.divider,
          thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.15), trackHeight: 6),
        child: Slider(value: _days.toDouble(), min: 1, max: 30, divisions: 29,
            onChanged: (v) => setState(() => _days = v.round())),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('1 day', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
        Text('30 days', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
      ]),
      const SizedBox(height: 24),
      Wrap(spacing: 8, children: [3,5,7,10,14].map((d) => GestureDetector(
        onTap: () => setState(() => _days = d),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _days == d ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _days == d ? AppColors.primary : AppColors.divider)),
          child: Text('${d}d', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600,
              color: _days == d ? Colors.white : AppColors.textPrimary)),
        ),
      )).toList()),
      const SizedBox(height: 28),
      Text('Start Date', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _startDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.primary)),
              child: child!),
          );
          if (picked != null) setState(() => _startDate = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trip starts on', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                '${_startDate.day} ${_mo(_startDate.month)} ${_startDate.year}',
                style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ])),
            Text('Change', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Returns: ${_endDate.day} ${_mo(_endDate.month)} ${_endDate.year}  (${_days} night${_days > 1 ? "s" : ""})',
        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  DateTime get _endDate => _startDate.add(Duration(days: _days));

  String _mo(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];

  // ── Step 3: Budget ───────────────────────────────────────────
  Widget _buildBudgetStep() {
    final budget = _effectiveBudget;
    final String label = budget < 150 ? 'Backpacker' : budget < 400 ? 'Budget' : budget < 1200 ? 'Mid-range' : 'Luxury';
    final Color labelColor = budget < 150 ? AppColors.green : budget < 400 ? AppColors.accent
        : budget < 1200 ? AppColors.primary : const Color(0xFF9B59B6);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("What's your budget?",
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Total trip budget in USD (all costs)', style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 28),

      // Budget display
      Center(child: Column(children: [
        Text('\$${budget.toInt()}',
            style: GoogleFonts.spaceGrotesk(fontSize: 68, fontWeight: FontWeight.w900, color: AppColors.dark)),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(color: labelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: labelColor)),
        ),
      ])),
      const SizedBox(height: 24),

      // Toggle: slider vs custom
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _useCustomBudget = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_useCustomBudget ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: !_useCustomBudget ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : null,
              ),
              child: Center(child: Text('Slider', style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: !_useCustomBudget ? AppColors.textPrimary : AppColors.grey))),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _useCustomBudget = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _useCustomBudget ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: _useCustomBudget ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : null,
              ),
              child: Center(child: Text('Custom Amount', style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _useCustomBudget ? AppColors.primary : AppColors.grey))),
            ),
          )),
        ]),
      ),
      const SizedBox(height: 20),

      if (!_useCustomBudget) ...[
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.15), trackHeight: 6),
          child: Slider(value: _budget, min: 50, max: 5000, divisions: 99,
              onChanged: (v) => setState(() => _budget = v)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('\$50', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
          Text('\$5,000', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
        ]),
        const SizedBox(height: 16),
        // Quick select
        Wrap(spacing: 8, runSpacing: 8, children: [100,200,350,500,1000,2000].map((v) => GestureDetector(
          onTap: () => setState(() => _budget = v.toDouble()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _budget == v.toDouble() ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _budget == v.toDouble() ? AppColors.primary : AppColors.divider)),
            child: Text('\$$v', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600,
                color: _budget == v.toDouble() ? Colors.white : AppColors.textPrimary)),
          ),
        )).toList()),
      ] else ...[
        TextField(
          controller: _customBudgetCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: GoogleFonts.spaceGrotesk(fontSize: 22, color: AppColors.grey),
            prefixIcon: Padding(padding: const EdgeInsets.only(left: 16, top: 14),
                child: Text('\$', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
          ),
        ),
        const SizedBox(height: 12),
        Text('Enter any amount — we\'ll find hotels and activities within your budget',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary)),
      ],

      const SizedBox(height: 20),
      _BudgetBreakdownCard(budget: budget, days: _days),
    ]);
  }

  // ── Step 4: Interests ────────────────────────────────────────
  Widget _buildInterestsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What interests you?',
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text("We'll personalise your itinerary and hotel picks",
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 24),
      Wrap(spacing: 10, runSpacing: 10,
        children: _allInterests.map((interest) {
          final clean = interest.split(' ').skip(1).join(' ');
          final sel = _interests.contains(clean);
          return GestureDetector(
            onTap: () => setState(() => sel ? _interests.remove(clean) : _interests.add(clean)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider),
                boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6)] : null,
              ),
              child: Text(interest, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500,
                  color: sel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
      if (_interests.isNotEmpty) ...[
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Text('${_interests.length} interest${_interests.length > 1 ? 's' : ''} selected',
                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    ]);
  }

  // ── Bottom button ────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    final isLast = _step == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))]),
      child: ElevatedButton(
        onPressed: () {
          if (_step == 2 && _useCustomBudget && _customBudgetCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a budget amount')));
            return;
          }
          if (isLast) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ItineraryPreviewScreen(
              destination: _destination, days: _days,
              budget: _effectiveBudget, interests: _interests.toList(),
              startDate: _startDate,
            )));
          } else {
            setState(() => _step++);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text(isLast ? '✨ Generate My Itinerary' : 'Continue',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

// ── Budget Breakdown Card ─────────────────────────────────────
class _BudgetBreakdownCard extends StatelessWidget {
  final double budget;
  final int days;
  const _BudgetBreakdownCard({required this.budget, required this.days});

  @override
  Widget build(BuildContext context) {
    final perDay     = days > 0 ? budget / days : budget;
    final hotelBudget  = perDay * 0.45;
    final foodBudget   = perDay * 0.25;
    final activityBudget = perDay * 0.20;
    final transportBudget = perDay * 0.10;
    final hotelCat = hotelBudget < 15 ? 'Hostels / dormitories'
        : hotelBudget < 40 ? 'Budget guesthouses'
        : hotelBudget < 100 ? 'Mid-range hotels'
        : hotelBudget < 200 ? 'Boutique resorts'
        : 'Luxury resorts';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.calculate_outlined, size: 16, color: Color(0xFF7B5800)),
          const SizedBox(width: 6),
          Text('Estimated daily breakdown (\$${perDay.toInt()}/day)',
              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF7B5800))),
        ]),
        const SizedBox(height: 12),
        _BudgetRow('🏨 Hotels ($hotelCat)', hotelBudget),
        _BudgetRow('🍛 Food & dining', foodBudget),
        _BudgetRow('🎭 Activities', activityBudget),
        _BudgetRow('🚗 Transport', transportBudget),
      ]),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double amount;
  const _BudgetRow(this.label, this.amount);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: const Color(0xFF7B5800)))),
      Text('\$${amount.toInt()}/day', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF7B5800))),
    ]),
  );
}
