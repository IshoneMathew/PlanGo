import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _travelers = 2;
  int _selectedPayment = 0;
  bool _hasInsurance = true;

  final List<_PayMethod> _payments = [
    _PayMethod(label: 'Visa •••• 4242', icon: Icons.credit_card, color: const Color(0xFF1A1F71)),
    _PayMethod(label: 'Mastercard •••• 8821', icon: Icons.credit_card, color: const Color(0xFFEB001B)),
    _PayMethod(label: 'PayPal', icon: Icons.account_balance_wallet_outlined, color: const Color(0xFF003087)),
  ];

  double get _basePrice => 59.0 * _travelers;
  double get _insuranceCost => _hasInsurance ? 12.0 * _travelers : 0;
  double get _total => _basePrice + _insuranceCost + 15.0; // service fee

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTripSummary(),
                    const SizedBox(height: 20),
                    _buildTravelersSection(),
                    const SizedBox(height: 20),
                    _buildPaymentSection(),
                    const SizedBox(height: 20),
                    _buildInsuranceSection(),
                    const SizedBox(height: 20),
                    _buildPriceBreakdown(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            ),
          ),
          const Expanded(child: Center(
            child: Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          )),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=200&q=80',
              width: 72, height: 72, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sigiriya Rock Fortress',
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
                  const SizedBox(width: 2),
                  Text('Sigiriya, Matale District',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.star, size: 13),
                  const SizedBox(width: 3),
                  Text('4.7 (2,498 reviews)', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$59', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('/person', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelersSection() {
    return _Section(
      title: 'Travelers',
      child: Row(
        children: [
          Expanded(
            child: Text('Number of travelers',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary)),
          ),
          _CounterButton(
            count: _travelers,
            onDec: () { if (_travelers > 1) setState(() => _travelers--); },
            onInc: () { if (_travelers < 10) setState(() => _travelers++); },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _Section(
      title: 'Payment Method',
      child: Column(
        children: _payments.asMap().entries.map((e) => GestureDetector(
          onTap: () => setState(() => _selectedPayment = e.key),
          child: Container(
            margin: EdgeInsets.only(bottom: e.key < _payments.length - 1 ? 10 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedPayment == e.key ? AppColors.primaryLight : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedPayment == e.key ? AppColors.primary : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: e.value.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(e.value.icon, color: e.value.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(e.value.label,
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ),
                if (_selectedPayment == e.key)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return _Section(
      title: 'Travel Insurance',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hasInsurance ? AppColors.primaryLight : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hasInsurance ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Coverage', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('\$12/person • Cancellation + Medical',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: _hasInsurance,
              onChanged: (v) => setState(() => _hasInsurance = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return _Section(
      title: 'Price Breakdown',
      child: Column(
        children: [
          _PriceRow(label: 'Base price ($_travelers × \$59/person)', value: '\$${_basePrice.toInt()}'),
          if (_hasInsurance) _PriceRow(label: 'Insurance ($_travelers × \$12)', value: '\$${(12.0 * _travelers).toInt()}'),
          _PriceRow(label: 'Service fee', value: '\$15'),
          const Divider(height: 20, color: AppColors.divider),
          _PriceRow(label: 'Total', value: '\$${_total.toInt()}', bold: true),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const BookingConfirmationScreen())),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text('Pay \$${_total.toInt()} Now',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _PayMethod {
  final String label;
  final IconData icon;
  final Color color;
  const _PayMethod({required this.label, required this.icon, required this.color});
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final int count;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _CounterButton({required this.count, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onDec,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.remove, size: 18, color: AppColors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$count', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        GestureDetector(
          onTap: onInc,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: GoogleFonts.spaceGrotesk(fontSize: bold ? 15 : 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? AppColors.textPrimary : AppColors.textSecondary))),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
