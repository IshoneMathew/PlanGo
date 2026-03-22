import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Destination> _all = [];
  List<Destination> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    final destinations = await FirebaseService.fetchDestinations();
    if (mounted) {
      setState(() {
        _all = destinations;
        _results = destinations;
        _loading = false;
      });
    }
  }

  void _search(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      _results = query.isEmpty
          ? _all
          : _all.where((d) =>
              d.name.toLowerCase().contains(query) ||
              d.location.toLowerCase().contains(query) ||
              d.province.toLowerCase().contains(query)).toList();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Discover', style: _style(28, FontWeight.w800, AppColors.textPrimary)),
        Text('Find your perfect Sri Lanka destination',
            style: _style(13, FontWeight.w400, AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _ctrl,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Search destinations, cities, provinces…',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.grey),
                  onPressed: () { _ctrl.clear(); _search(''); })
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(children: [
        Text('${_results.length} destination${_results.length != 1 ? 's' : ''}',
            style: _style(13, FontWeight.w600, AppColors.textSecondary)),
        const Spacer(),
        const Icon(Icons.tune_outlined, size: 16, color: AppColors.grey),
        const SizedBox(width: 4),
        Text('Filter', style: _style(13, FontWeight.w500, AppColors.grey)),
      ]),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off_outlined, size: 60, color: AppColors.grey),
        const SizedBox(height: 16),
        Text('No results for "${_ctrl.text}"',
            style: _style(15, FontWeight.w600, AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text('Try a different city or province',
            style: _style(12, FontWeight.w400, AppColors.grey)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _results.length,
      itemBuilder: (_, i) => _SearchCard(
        destination: _results[i],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: _results[i]))),
      ),
    );
  }

  TextStyle _style(double sz, FontWeight fw, Color c) =>
      GoogleFonts.spaceGrotesk(fontSize: sz, fontWeight: fw, color: c);
}

class _SearchCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  const _SearchCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: Image.network(destination.imageUrl,
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 90, height: 90, color: Colors.grey.shade200)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(destination.name,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
                  const SizedBox(width: 2),
                  Expanded(child: Text(destination.location,
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey),
                      overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.star, size: 13),
                  const SizedBox(width: 3),
                  Text('${destination.rating}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('\$${destination.pricePerPerson.toInt()}/person',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
          ),
        ]),
      ),
    );
  }
}
