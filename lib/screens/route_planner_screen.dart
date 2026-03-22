import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import '../data/itinerary_data.dart';
import 'my_trips_screen.dart';

// ─── CONFIG ───────────────────────────────────────────────────────
const _kApiKey          = 'AIzaSyCdFJt4KKCYwxM3k6_poy7hj9Mo5xBgD7I';
const _kDirectionsUrl   = 'https://maps.googleapis.com/maps/api/directions/json';
const _kNearbyUrl       = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
const _kAutocompleteUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
const _kDetailsUrl      = 'https://maps.googleapis.com/maps/api/place/details/json';
const _kSriLankaCentre  = LatLng(7.8731, 80.7718);

// ─── MODELS ───────────────────────────────────────────────────────
class PlaceResult {
  final String placeId, name, address;
  final double lat, lng;
  const PlaceResult({required this.placeId, required this.name,
      required this.address, required this.lat, required this.lng});
  LatLng get latLng => LatLng(lat, lng);
}

class RouteStop {
  final PlaceResult place;
  bool isAdded;
  RouteStop({required this.place, this.isAdded = false});
}

class _RouteData {
  final List<LatLng> polylinePoints;
  final int totalDurationSec, totalDistanceM;
  const _RouteData({required this.polylinePoints,
      required this.totalDurationSec, required this.totalDistanceM});
}

// ─── MAPS SERVICE ─────────────────────────────────────────────────
class _MapsService {
  static final _allPlaces = <PlaceResult>[
    const PlaceResult(placeId:'p1',  name:'Sigiriya Rock Fortress',       address:'Sigiriya, Matale District',         lat:7.9570, lng:80.7603),
    const PlaceResult(placeId:'p2',  name:'Temple of the Tooth',          address:'Kandy, Kandy District',             lat:7.2931, lng:80.6413),
    const PlaceResult(placeId:'p3',  name:'Galle Fort',                   address:'Galle, Southern Province',          lat:6.0267, lng:80.2170),
    const PlaceResult(placeId:'p4',  name:'Mirissa Beach',                address:'Mirissa, Matara District',          lat:5.9483, lng:80.4716),
    const PlaceResult(placeId:'p5',  name:'Ella Rock',                    address:'Ella, Badulla District',            lat:6.8667, lng:81.0466),
    const PlaceResult(placeId:'p6',  name:'Yala National Park',           address:'Yala, Hambantota District',         lat:6.3728, lng:81.5219),
    const PlaceResult(placeId:'p7',  name:'Dambulla Cave Temple',         address:'Dambulla, Matale District',         lat:7.8567, lng:80.6493),
    const PlaceResult(placeId:'p8',  name:'Arugam Bay',                   address:'Ampara District, Eastern Province', lat:6.8400, lng:81.8310),
    const PlaceResult(placeId:'p9',  name:'Colombo Fort',                 address:'Colombo, Western Province',         lat:6.9271, lng:79.8612),
    const PlaceResult(placeId:'p10', name:'Nuwara Eliya',                 address:'Nuwara Eliya District',             lat:6.9497, lng:80.7891),
    const PlaceResult(placeId:'p11', name:'Trincomalee Beach',            address:'Trincomalee, Eastern Province',     lat:8.5874, lng:81.2152),
    const PlaceResult(placeId:'p12', name:'Polonnaruwa Ancient City',     address:'Polonnaruwa District',              lat:7.9403, lng:81.0188),
    const PlaceResult(placeId:'p13', name:'Anuradhapura Sacred City',     address:'Anuradhapura District',             lat:8.3114, lng:80.4037),
    const PlaceResult(placeId:'p14', name:'Unawatuna Beach',              address:'Galle District, Southern Province', lat:6.0100, lng:80.2490),
    const PlaceResult(placeId:'p15', name:'Horton Plains',                address:'Nuwara Eliya District',             lat:6.8009, lng:80.8075),
    const PlaceResult(placeId:'p16', name:'Pinnawala Elephant Orphanage', address:'Kegalle District',                  lat:7.3004, lng:80.3839),
    const PlaceResult(placeId:'p17', name:'Hikkaduwa Beach',              address:'Galle District',                    lat:6.1395, lng:80.1054),
    const PlaceResult(placeId:'p18', name:'Negombo Beach',                address:'Negombo, Western Province',         lat:7.2081, lng:79.8358),
    const PlaceResult(placeId:'p19', name:'Nine Arch Bridge',             address:'Ella, Badulla District',            lat:6.8753, lng:81.0590),
    const PlaceResult(placeId:'p20', name:'Minneriya National Park',      address:'Polonnaruwa District',              lat:8.0297, lng:80.8997),
    const PlaceResult(placeId:'p21', name:'Kandy City Centre',            address:'Kandy, Central Province',           lat:7.2906, lng:80.6337),
    const PlaceResult(placeId:'p22', name:'Galle City',                   address:'Galle, Southern Province',          lat:6.0535, lng:80.2210),
    const PlaceResult(placeId:'p23', name:'Ella',                         address:'Ella, Badulla District',            lat:6.8750, lng:81.0460),
    const PlaceResult(placeId:'p24', name:'Colombo City',                 address:'Colombo, Western Province',         lat:6.9271, lng:79.8612),
    const PlaceResult(placeId:'p25', name:'Bentota Beach',                address:'Bentota, Galle District',           lat:6.4271, lng:79.9946),
  ];

  // ── Autocomplete ──────────────────────────────────────────────
  static Future<List<PlaceResult>> autocomplete(String input) async {
    if (input.length < 2) return _allPlaces.take(8).toList();
    try {
      final res = await http.get(Uri.parse(
          '$_kAutocompleteUrl?input=${Uri.encodeComponent(input)}'
          '&components=country:lk&key=$_kApiKey')).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return _mockSearch(input);
      final preds = jsonDecode(res.body)['predictions'] as List? ?? [];
      if (preds.isEmpty) return _mockSearch(input);
      final results = await Future.wait(preds.take(6).map((p) => _details(p['place_id'])));
      return results.whereType<PlaceResult>().toList();
    } catch (_) { return _mockSearch(input); }
  }

  static Future<PlaceResult?> _details(String placeId) async {
    try {
      final res = await http.get(Uri.parse('$_kDetailsUrl?place_id=$placeId'
          '&fields=place_id,name,formatted_address,geometry&key=$_kApiKey'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final r = jsonDecode(res.body)['result'];
      return PlaceResult(
        placeId: r['place_id'] ?? placeId, name: r['name'] ?? '',
        address: r['formatted_address'] ?? '',
        lat: (r['geometry']['location']['lat'] as num).toDouble(),
        lng: (r['geometry']['location']['lng'] as num).toDouble(),
      );
    } catch (_) { return null; }
  }

  // ── Directions with real road polyline ────────────────────────
  static Future<_RouteData?> getRoute({
    required PlaceResult origin, required PlaceResult destination,
    List<PlaceResult> waypoints = const [],
  }) async {
    try {
      String wp = '';
      if (waypoints.isNotEmpty) {
        wp = '&waypoints=optimize:false|${waypoints.map((w) => '${w.lat},${w.lng}').join('|')}';
      }
      final url = '$_kDirectionsUrl?origin=${origin.lat},${origin.lng}'
          '&destination=${destination.lat},${destination.lng}'
          '&mode=driving$wp&key=$_kApiKey';
      debugPrint('[Route] $url');
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return _mockRoute(origin, destination, waypoints);
      final body = jsonDecode(res.body);
      if (body['status'] != 'OK') {
        debugPrint('[Route] API: ${body['status']} — ${body['error_message'] ?? ''}');
        return _mockRoute(origin, destination, waypoints);
      }
      final route = body['routes'][0];
      final encoded = route['overview_polyline']['points'] as String;
      final legs = route['legs'] as List;
      int dur = 0, dist = 0;
      for (final l in legs) {
        dur  += (l['duration']?['value']  as int? ?? 0);
        dist += (l['distance']?['value']  as int? ?? 0);
      }
      final pts = _decodePolyline(encoded);
      debugPrint('[Route] ${pts.length} polyline points decoded');
      return _RouteData(polylinePoints: pts, totalDurationSec: dur, totalDistanceM: dist);
    } catch (e) {
      debugPrint('[Route] Exception: $e');
      return _mockRoute(origin, destination, waypoints);
    }
  }

  // ── Nearby tourist attractions along the entire route ─────────
  // Uses multiple sample points along the route for better coverage
  static Future<List<PlaceResult>> attractionsAlongRoute({
    required PlaceResult origin,
    required PlaceResult destination,
    List<PlaceResult> alreadyAdded = const [],
  }) async {
    // Sample 3 points: 25%, 50%, 75% along the route
    final samplePoints = [
      LatLng(origin.lat + (destination.lat - origin.lat) * 0.25,
             origin.lng + (destination.lng - origin.lng) * 0.25),
      LatLng(origin.lat + (destination.lat - origin.lat) * 0.5,
             origin.lng + (destination.lng - origin.lng) * 0.5),
      LatLng(origin.lat + (destination.lat - origin.lat) * 0.75,
             origin.lng + (destination.lng - origin.lng) * 0.75),
    ];

    final seen = <String>{};
    final results = <PlaceResult>[];

    // Try live API for each sample point
    for (final pt in samplePoints) {
      try {
        final res = await http.get(Uri.parse(
            '$_kNearbyUrl?location=${pt.latitude},${pt.longitude}'
            '&radius=45000&type=tourist_attraction&key=$_kApiKey'))
            .timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body)['results'] as List? ?? [];
          for (final r in list.take(4)) {
            final id = r['place_id'] as String? ?? '';
            if (seen.contains(id)) continue;
            seen.add(id);
            results.add(PlaceResult(
              placeId: id, name: r['name'] ?? '',
              address: r['vicinity'] ?? '',
              lat: (r['geometry']['location']['lat'] as num).toDouble(),
              lng: (r['geometry']['location']['lng'] as num).toDouble(),
            ));
          }
        }
      } catch (_) {}
    }

    // Fallback: use mock data filtered by proximity to route
    if (results.isEmpty) {
      return _mockAlongRoute(origin, destination);
    }

    // Filter out origin, destination and already-added stops
    final skipIds = {origin.placeId, destination.placeId, ...alreadyAdded.map((p) => p.placeId)};
    return results.where((p) => !skipIds.contains(p.placeId)).take(8).toList();
  }

  // ── Mock data ─────────────────────────────────────────────────
  static List<PlaceResult> _mockSearch(String q) => _allPlaces
      .where((p) => p.name.toLowerCase().contains(q.toLowerCase()) ||
          p.address.toLowerCase().contains(q.toLowerCase()))
      .take(6).toList();

  static _RouteData _mockRoute(PlaceResult o, PlaceResult d, List<PlaceResult> wps) {
    final all = [o, ...wps, d];
    final pts = <LatLng>[];
    double dist = 0;
    for (int i = 0; i < all.length - 1; i++) {
      pts.addAll(_interpolate(all[i].latLng, all[i + 1].latLng, steps: 16));
      dist += _haversineKm(all[i].lat, all[i].lng, all[i+1].lat, all[i+1].lng);
    }
    return _RouteData(polylinePoints: pts,
        totalDurationSec: (dist / 60 * 3600).round(),
        totalDistanceM: (dist * 1000).round());
  }

  static List<PlaceResult> _mockAlongRoute(PlaceResult o, PlaceResult d) {
    // Return places whose position is geographically between origin and destination
    final minLat = math.min(o.lat, d.lat) - 0.5;
    final maxLat = math.max(o.lat, d.lat) + 0.5;
    final minLng = math.min(o.lng, d.lng) - 0.5;
    final maxLng = math.max(o.lng, d.lng) + 0.5;

    final inBounds = _allPlaces.where((p) =>
      p.lat >= minLat && p.lat <= maxLat &&
      p.lng >= minLng && p.lng <= maxLng &&
      p.placeId != o.placeId && p.placeId != d.placeId,
    ).toList();

    // Sort by distance from the midpoint
    final midLat = (o.lat + d.lat) / 2;
    final midLng = (o.lng + d.lng) / 2;
    inBounds.sort((a, b) =>
        _haversineKm(midLat, midLng, a.lat, a.lng)
            .compareTo(_haversineKm(midLat, midLng, b.lat, b.lng)));

    // Fall back to closest 6 if nothing in bounds
    if (inBounds.isEmpty) {
      final sorted = List<PlaceResult>.from(_allPlaces)
        ..sort((a, b) => _haversineKm(midLat, midLng, a.lat, a.lng)
            .compareTo(_haversineKm(midLat, midLng, b.lat, b.lng)));
      return sorted.where((p) => p.placeId != o.placeId && p.placeId != d.placeId)
          .take(6).toList();
    }
    return inBounds.take(8).toList();
  }

  // ── Polyline decoder ──────────────────────────────────────────
  static List<LatLng> _decodePolyline(String encoded) {
    final pts = <LatLng>[];
    int idx = 0, lat = 0, lng = 0;
    while (idx < encoded.length) {
      int b, shift = 0, result = 0;
      do { b = encoded.codeUnitAt(idx++) - 63; result |= (b & 0x1f) << shift; shift += 5; } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0; result = 0;
      do { b = encoded.codeUnitAt(idx++) - 63; result |= (b & 0x1f) << shift; shift += 5; } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      pts.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return pts;
  }

  static List<LatLng> _interpolate(LatLng a, LatLng b, {int steps = 12}) =>
      List.generate(steps + 1, (i) => LatLng(
          a.latitude  + (b.latitude  - a.latitude)  * i / steps,
          a.longitude + (b.longitude - a.longitude) * i / steps));

  static double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.pow(math.sin(dLng / 2), 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static String formatDur(int s) {
    final h = s ~/ 3600; final m = (s % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m} mins';
  }
}

// ─────────────────────────────────────────────────────────────────
// ROUTE PLANNER SCREEN
// ─────────────────────────────────────────────────────────────────
class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});
  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _mapCtrl = Completer<GoogleMapController>();

  PlaceResult? _origin;
  PlaceResult? _destination;

  final List<RouteStop> _addedStops   = [];
  final List<RouteStop> _suggestions  = [];

  Set<Polyline> _polylines = {};
  Set<Marker>   _markers   = {};

  bool _loadingRoute        = false;
  bool _loadingSuggestions  = false;
  bool _suggestionsLoaded   = false; // true once we've fetched suggestions
  int  _totalDurSec        = 0;
  int  _totalDistM         = 0;
  bool _mapExpanded        = false;

  // ── Book trip state ──────────────────────────────────────────
  int    _travelers = 1;
  double _budget    = 500;
  bool   _booking   = false;

  // ── BUILD ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasRoute = _origin != null && _destination != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: hasRoute && _mapExpanded
                  ? _buildExpandedMap()
                  : _buildScrollContent(hasRoute),
            ),
            if (hasRoute) _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      color: Colors.white,
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Route Planner', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Pick stops · book as a trip', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        if (_origin != null && _destination != null)
          GestureDetector(
            onTap: () => setState(() => _mapExpanded = !_mapExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: _mapExpanded ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(_mapExpanded ? Icons.map : Icons.map_outlined, size: 14,
                    color: _mapExpanded ? Colors.white : AppColors.primary),
                const SizedBox(width: 4),
                Text(_mapExpanded ? 'List' : 'Map',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600,
                        color: _mapExpanded ? Colors.white : AppColors.primary)),
              ]),
            ),
          ),
      ]),
    );
  }

  // ── SCROLL CONTENT ────────────────────────────────────────────
  Widget _buildScrollContent(bool hasRoute) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        _buildLocationPickers(),
        if (hasRoute) ...[
          const SizedBox(height: 16),
          _buildMapCard(),
          const SizedBox(height: 16),
          _buildRouteSummary(),
        ],
        if (_addedStops.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAddedStops(),
        ],
        if (_suggestions.isNotEmpty || _loadingSuggestions) ...[
          const SizedBox(height: 20),
          _buildSuggestions(),
        ],
        if (hasRoute) ...[
          const SizedBox(height: 20),
          _buildTripOptions(),
        ],
        const SizedBox(height: 100),
      ]),
    );
  }

  // ── EMBEDDED MAP CARD ─────────────────────────────────────────
  Widget _buildMapCard() {
    return GestureDetector(
      onTap: () => setState(() => _mapExpanded = true),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(target: _kSriLankaCentre, zoom: 7.5),
              onMapCreated: (ctrl) {
                if (!_mapCtrl.isCompleted) _mapCtrl.complete(ctrl);
                Future.delayed(const Duration(milliseconds: 400), _fitBounds);
              },
              polylines: _polylines,
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
            if (_loadingRoute)
              Container(color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            Positioned(top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.fullscreen, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('Expand', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white)),
                ]),
              )),
            // Route info overlay bottom
            if (!_loadingRoute && _totalDurSec > 0)
              Positioned(bottom: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(_MapsService.formatDur(_totalDurSec),
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.straighten, color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text('${(_totalDistM / 1000).toStringAsFixed(0)} km',
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white70)),
                  ]),
                )),
          ]),
        ),
      ),
    );
  }

  // ── EXPANDED FULL MAP ─────────────────────────────────────────
  Widget _buildExpandedMap() {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: _kSriLankaCentre, zoom: 7.5),
        onMapCreated: (ctrl) {
          if (!_mapCtrl.isCompleted) _mapCtrl.complete(ctrl);
          Future.delayed(const Duration(milliseconds: 400), _fitBounds);
        },
        polylines: _polylines,
        markers: _markers,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        compassEnabled: true,
      ),
      Positioned(left: 16, right: 16, bottom: 16,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12)]),
          child: Row(children: [
            _MiniPill(Icons.access_time, _MapsService.formatDur(_totalDurSec), AppColors.primary),
            const SizedBox(width: 8),
            _MiniPill(Icons.straighten, '${(_totalDistM / 1000).toStringAsFixed(0)} km', AppColors.green),
            const SizedBox(width: 8),
            _MiniPill(Icons.place, '${_addedStops.length + 2} stops', AppColors.accent),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _mapExpanded = false),
              child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.fullscreen_exit, size: 18, color: AppColors.textPrimary)),
            ),
          ]),
        )),
      if (_loadingRoute)
        Container(color: Colors.black26,
            child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
    ]);
  }

  // ── LOCATION PICKERS ─────────────────────────────────────────
  Widget _buildLocationPickers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)]),
      child: Column(children: [
        _LocField(icon: Icons.my_location_rounded, iconColor: AppColors.green,
            hint: 'Your starting point', value: _origin?.name,
            onTap: () => _pickLocation(isOrigin: true)),
        Padding(padding: const EdgeInsets.only(left: 18, top: 2, bottom: 2),
            child: Column(children: List.generate(3, (_) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2), width: 3, height: 3,
                decoration: const BoxDecoration(color: AppColors.divider, shape: BoxShape.circle))))),
        _LocField(icon: Icons.location_on_rounded, iconColor: AppColors.accent,
            hint: 'Choose destination', value: _destination?.name,
            onTap: () => _pickLocation(isOrigin: false)),
        if (_origin != null || _destination != null)
          Align(alignment: Alignment.centerRight,
            child: GestureDetector(onTap: _swap,
              child: Container(margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Swap', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                ])))),
      ]),
    );
  }

  // ── ROUTE SUMMARY ────────────────────────────────────────────
  Widget _buildRouteSummary() {
    final all = [_origin!, ..._addedStops.map((s) => s.place), _destination!];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1F36), Color(0xFF2D3561)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF1A1F36).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.route, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Text('Route Summary', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white54)),
          const Spacer(),
          if (_addedStops.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text('${_addedStops.length} stop${_addedStops.length > 1 ? 's' : ''}',
                style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          _SumPill(Icons.access_time, _MapsService.formatDur(_totalDurSec), const Color(0xFF00C6FF)),
          _SumPill(Icons.straighten, '${(_totalDistM / 1000).toStringAsFixed(0)} km', const Color(0xFF71B280)),
          _SumPill(Icons.place, '${all.length} points', AppColors.accent),
        ]),
        const SizedBox(height: 14),
        ...all.asMap().entries.map((e) => _TimelineItem(
          name: e.value.name, sub: e.value.address,
          isFirst: e.key == 0, isLast: e.key == all.length - 1,
          isStop: e.key > 0 && e.key < all.length - 1,
          showLine: e.key < all.length - 1)),
      ]),
    );
  }

  // ── ADDED STOPS ───────────────────────────────────────────────
  Widget _buildAddedStops() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Your Stops', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: Text('${_addedStops.length}',
                style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
      ]),
      const SizedBox(height: 10),
      ReorderableListView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: _addedStops.length,
        onReorder: (old, nw) {
          setState(() { if (nw > old) nw--; final s = _addedStops.removeAt(old); _addedStops.insert(nw, s); });
          _computeRoute();
        },
        itemBuilder: (_, i) => _StopTile(
          key: ValueKey('${_addedStops[i].place.placeId}_$i'),
          stop: _addedStops[i], index: i,
          onRemove: () { setState(() => _addedStops.removeAt(i)); _computeRoute(); }),
      ),
    ]);
  }

  // ── SUGGESTIONS ALONG ROUTE ───────────────────────────────────
  Widget _buildSuggestions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.auto_awesome, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text('Along Your Route', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 3),
      Text('Tourist spots near your route — tap + to add, × to dismiss',
          style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
      const SizedBox(height: 12),
      if (_loadingSuggestions)
        const Center(child: Padding(padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
      else
        ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggestions.length,
          itemBuilder: (_, i) {
            final s = _suggestions[i];
            final added = _addedStops.any((a) => a.place.placeId == s.place.placeId);
            final isEndpoint = s.place.placeId == _origin?.placeId ||
                s.place.placeId == _destination?.placeId;
            if (isEndpoint) return const SizedBox.shrink();
            return _SuggestionTile(
              stop: s, alreadyAdded: added,
              onAdd: added ? null : () => _addStop(s),
              onDismiss: () => setState(() => _suggestions.removeAt(i)),
            );
          }),
    ]);
  }

  // ── TRIP OPTIONS (budget + travelers) ─────────────────────────
  Widget _buildTripOptions() {
    final totalDistKm = _totalDistM / 1000;
    final estimatedDays = (totalDistKm / 200).ceil().clamp(1, 14);
    final costPerPerson = _budget;
    final totalCost = costPerPerson * _travelers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Trip Options', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14),

        // Estimated duration info
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 15),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Based on ${(_totalDistM / 1000).toStringAsFixed(0)} km — estimated $estimatedDays day${estimatedDays > 1 ? 's' : ''}',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.primary))),
          ])),
        const SizedBox(height: 14),

        // Travelers
        Row(children: [
          const Icon(Icons.people_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('Travelers', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Spacer(),
          _CounterButton(icon: Icons.remove, onTap: _travelers > 1 ? () => setState(() => _travelers--) : null),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('$_travelers', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          _CounterButton(icon: Icons.add, onTap: _travelers < 20 ? () => setState(() => _travelers++) : null),
        ]),
        const SizedBox(height: 16),

        // Budget per person
        Row(children: [
          const Icon(Icons.attach_money, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('Budget per person', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Spacer(),
          Text('\$${_budget.toInt()}',
              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.dark)),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.1), trackHeight: 4),
          child: Slider(value: _budget, min: 50, max: 5000, divisions: 99,
              onChanged: (v) => setState(() => _budget = v)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('\$50', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
          Text('\$5,000', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.grey)),
        ]),
        const SizedBox(height: 12),

        // Per person indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Per person', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
              Text('\$${_budget.toInt()}',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ])),
            Container(width: 1, height: 36, color: AppColors.divider),
            Expanded(child: Padding(padding: const EdgeInsets.only(left: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total ($_travelers person${_travelers > 1 ? 's' : ''})',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
                Text('\$${totalCost.toInt()}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dark)),
              ]))),
          ]),
        ),
      ]),
    );
  }

  // ── BOTTOM BAR ───────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(_MapsService.formatDur(_totalDurSec),
              style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('\$${_budget.toInt()}/person · ${_addedStops.length + 2} stops',
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        ElevatedButton.icon(
          onPressed: _booking ? null : () => _bookTrip(context),
          icon: _booking
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
          label: Text(_booking ? 'Saving…' : 'Book Trip',
              style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark, minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ]),
    );
  }

  // ── LOGIC ────────────────────────────────────────────────────
  Future<void> _pickLocation({required bool isOrigin}) async {
    final result = await showModalBottomSheet<PlaceResult>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(
        title: isOrigin ? 'Starting Point' : 'Destination',
        hint: isOrigin ? 'Search your location' : 'Search destination in Sri Lanka',
        showGpsOption: isOrigin),
    );
    if (result == null) return;
    setState(() {
      if (isOrigin) _origin = result; else _destination = result;
      _suggestions.clear(); _addedStops.clear();
      _suggestionsLoaded = false;
      _polylines = {}; _markers = {};
      _totalDurSec = 0; _totalDistM = 0;
    });
    if (_origin != null && _destination != null) _computeRoute();
  }

  void _swap() {
    setState(() {
      final tmp = _origin; _origin = _destination; _destination = tmp;
      _suggestions.clear(); _addedStops.clear();
      _suggestionsLoaded = false;
      _polylines = {}; _markers = {};
      _totalDurSec = 0; _totalDistM = 0;
    });
    if (_origin != null && _destination != null) _computeRoute();
  }

  Future<void> _computeRoute() async {
    if (_origin == null || _destination == null) return;
    final needSuggestions = !_suggestionsLoaded;
    setState(() {
      _loadingRoute = true;
      if (needSuggestions) _loadingSuggestions = true;
    });

    final routeFuture = _MapsService.getRoute(
      origin: _origin!, destination: _destination!,
      waypoints: _addedStops.map((s) => s.place).toList());

    final suggFuture = needSuggestions
        ? _MapsService.attractionsAlongRoute(
            origin: _origin!, destination: _destination!,
            alreadyAdded: _addedStops.map((s) => s.place).toList())
        : Future.value(<PlaceResult>[]);

    final results = await Future.wait([routeFuture, suggFuture]);
    if (!mounted) return;

    final data = results[0] as _RouteData?;
    final suggPlaces = results[1] as List<PlaceResult>;

    setState(() {
      _totalDurSec = data?.totalDurationSec ?? 0;
      _totalDistM  = data?.totalDistanceM  ?? 0;
      _loadingRoute = false;
      _loadingSuggestions = false;
      if (needSuggestions) {
        _suggestionsLoaded = true;
        _suggestions.clear();
        // Filter out origin, destination and already added stops
        final skipIds = {
          _origin!.placeId, _destination!.placeId,
          ..._addedStops.map((s) => s.place.placeId)
        };
        _suggestions.addAll(
          suggPlaces.where((p) => !skipIds.contains(p.placeId))
              .map((p) => RouteStop(place: p)));
      }
    });

    _updateMapOverlays(data?.polylinePoints ?? []);
  }

  void _addStop(RouteStop stop) {
    setState(() {
      _addedStops.add(RouteStop(place: stop.place, isAdded: true));
      // Remove from suggestions immediately so it doesn't stay in the list
      _suggestions.removeWhere((s) => s.place.placeId == stop.place.placeId);
    });
    // Recompute route with the new waypoint — don't reload suggestions
    _recomputeRouteOnly();
  }

  // Recompute route only (don't touch suggestions list)
  Future<void> _recomputeRouteOnly() async {
    if (_origin == null || _destination == null) return;
    setState(() => _loadingRoute = true);
    final data = await _MapsService.getRoute(
      origin: _origin!,
      destination: _destination!,
      waypoints: _addedStops.map((s) => s.place).toList(),
    );
    if (!mounted) return;
    setState(() {
      _totalDurSec = data?.totalDurationSec ?? 0;
      _totalDistM  = data?.totalDistanceM  ?? 0;
      _loadingRoute = false;
    });
    _updateMapOverlays(data?.polylinePoints ?? []);
  }

  void _updateMapOverlays(List<LatLng> polyPts) {
    final all = [_origin!, ..._addedStops.map((s) => s.place), _destination!];
    final markers = <Marker>{};
    for (int i = 0; i < all.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('m_$i'), position: all[i].latLng,
        infoWindow: InfoWindow(title: all[i].name, snippet: all[i].address),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == 0 ? BitmapDescriptor.hueGreen
              : i == all.length - 1 ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueAzure),
      ));
    }

    // Also add suggestion markers in yellow (so user sees what's nearby)
    for (final s in _suggestions) {
      markers.add(Marker(
        markerId: MarkerId('sugg_${s.place.placeId}'),
        position: s.place.latLng,
        infoWindow: InfoWindow(title: s.place.name, snippet: 'Tap + to add as stop'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        alpha: 0.8,
      ));
    }

    final polylines = <Polyline>{};
    if (polyPts.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: polyPts,
        color: const Color(0xFF006FFD),
        width: 5,
        startCap: Cap.roundCap, endCap: Cap.roundCap, jointType: JointType.round,
        patterns: [],
      ));
    }

    setState(() { _markers = markers; _polylines = polylines; });
    _fitBounds();
  }

  Future<void> _fitBounds() async {
    if (_origin == null || _destination == null) return;
    try {
      final ctrl = await _mapCtrl.future;
      final all = [_origin!.latLng, _destination!.latLng, ..._addedStops.map((s) => s.place.latLng)];
      final minLat = all.map((p) => p.latitude).reduce(math.min);
      final maxLat = all.map((p) => p.latitude).reduce(math.max);
      final minLng = all.map((p) => p.longitude).reduce(math.min);
      final maxLng = all.map((p) => p.longitude).reduce(math.max);
      const pad = 0.18;
      ctrl.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat - pad, minLng - pad), northeast: LatLng(maxLat + pad, maxLng + pad)), 60));
    } catch (_) {}
  }

  // ── BOOK & SAVE TRIP ─────────────────────────────────────────
  Future<void> _bookTrip(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() => _booking = true);

    // Build the destination name from stop cities
    final stopNames = [_origin!.name, ..._addedStops.map((s) => s.place.name), _destination!.name];
    final destName = '${_origin!.name} → ${_destination!.name}';

    // Generate day itineraries for each stop
    final totalDistKm = _totalDistM / 1000;
    final estimatedDays = (totalDistKm / 200).ceil().clamp(1, 14);
    final plans = ItineraryData.getDayPlans(_destination!.name, estimatedDays);

    final itinerary = List.generate(estimatedDays, (i) {
      final plan = plans[i];
      return DayItinerary(
        day: i + 1,
        activities: List<String>.from(plan['activities'] as List),
        lastStop: plan['stop'] as String,
        imageUrl: plan['image'] as String,
      );
    });

    final trip = BookedTrip(
      id: '',
      userId: uid,
      destination: destName,
      days: estimatedDays,
      budget: _budget * _travelers,
      totalCost: _budget * _travelers,
      interests: stopNames,
      itinerary: itinerary,
      transportMode: 'car',
      createdAt: DateTime.now(),
      status: 'upcoming',
    );

    try {
      await TripService.saveTrip(trip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('🎉 Route trip saved to My Trips!'), backgroundColor: AppColors.green));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MyTripsScreen()), (r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _booking = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.red));
      }
    }
  }
}

// ─── SEARCH SHEET ─────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final String title, hint;
  final bool showGpsOption;
  const _SearchSheet({required this.title, required this.hint, this.showGpsOption = false});
  @override State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  List<PlaceResult> _results = [];
  bool _loading = false;

  @override void initState() { super.initState(); _results = _MapsService._allPlaces.take(8).toList(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _search(String q) async {
    if (q.isEmpty) { setState(() => _results = _MapsService._allPlaces.take(8).toList()); return; }
    setState(() => _loading = true);
    final r = await _MapsService.autocomplete(q);
    if (mounted) setState(() { _results = r; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
    builder: (_, sc) => Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            TextField(controller: _ctrl, onChanged: _search, autofocus: true,
              decoration: InputDecoration(hintText: widget.hint,
                prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
                suffixIcon: _loading ? const Padding(padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))) : null)),
          ])),
        if (widget.showGpsOption) ...[
          ListTile(
            onTap: () => Navigator.pop(context, const PlaceResult(
                placeId: 'gps', name: 'My Current Location',
                address: 'Using GPS', lat: 6.9271, lng: 79.8612)),
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.my_location, color: AppColors.green, size: 20)),
            title: Text('Use Current Location', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.green)),
            subtitle: Text('Detect via GPS', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.grey))),
          const Divider(height: 1, color: AppColors.divider),
        ],
        Expanded(child: ListView.separated(controller: sc,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, color: AppColors.divider),
          itemBuilder: (_, i) {
            final p = _results[i];
            return ListTile(onTap: () => Navigator.pop(context, p),
              leading: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.place, color: AppColors.primary, size: 20)),
              title: Text(p.name, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              subtitle: Text(p.address, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis));
          })),
      ]),
    ),
  );
}

// ─── SMALL WIDGETS ────────────────────────────────────────────────
class _LocField extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String hint; final String? value; final VoidCallback onTap;
  const _LocField({required this.icon, required this.iconColor, required this.hint, required this.onTap, this.value});
  @override
  Widget build(BuildContext context) {
    final has = value != null && value!.isNotEmpty;
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14),
            border: has ? Border.all(color: iconColor.withOpacity(0.3), width: 1.5) : null),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 16)),
          const SizedBox(width: 12),
          Expanded(child: has
              ? Text(value!, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)
              : Text(hint, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.grey))),
          Icon(has ? Icons.edit_outlined : Icons.chevron_right, color: AppColors.grey, size: 18),
        ]),
      ));
  }
}

class _SumPill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SumPill(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 12), const SizedBox(width: 4),
      Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ]));
}

class _MiniPill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _MiniPill(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: color, size: 14), const SizedBox(width: 4),
    Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
  ]);
}

class _TimelineItem extends StatelessWidget {
  final String name, sub; final bool isFirst, isLast, isStop, showLine;
  const _TimelineItem({required this.name, required this.sub, required this.isFirst,
      required this.isLast, required this.isStop, required this.showLine});
  @override
  Widget build(BuildContext context) {
    final col = isFirst ? AppColors.green : isLast ? AppColors.accent : AppColors.primary;
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
        if (showLine) Expanded(child: Container(width: 2, color: Colors.white24)),
      ]),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: EdgeInsets.only(bottom: showLine ? 12.0 : 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
            if (isStop) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
                child: Text('stop', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white70))),
          ]),
          Text(sub, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]))),
    ]));
  }
}

class _StopTile extends StatelessWidget {
  final RouteStop stop; final int index; final VoidCallback onRemove;
  const _StopTile({super.key, required this.stop, required this.index, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Row(children: [
      Container(width: 28, height: 28,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('${index + 1}',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(stop.place.name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(stop.place.address, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      const SizedBox(width: 8),
      const Icon(Icons.drag_handle, color: AppColors.grey, size: 20),
      const SizedBox(width: 4),
      GestureDetector(onTap: onRemove,
          child: Container(width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, color: AppColors.red, size: 14))),
    ]),
  );
}

class _SuggestionTile extends StatelessWidget {
  final RouteStop stop; final bool alreadyAdded;
  final VoidCallback? onAdd; final VoidCallback onDismiss;
  const _SuggestionTile({required this.stop, required this.alreadyAdded, this.onAdd, required this.onDismiss});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Row(children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.place, color: AppColors.primary, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(stop.place.name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(stop.place.address, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      const SizedBox(width: 8),
      // Dismiss button
      GestureDetector(onTap: onDismiss,
          child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, color: AppColors.grey, size: 14))),
      const SizedBox(width: 6),
      // Add button
      GestureDetector(onTap: onAdd,
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: alreadyAdded ? AppColors.green : AppColors.primary,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(alreadyAdded ? Icons.check : Icons.add, color: Colors.white, size: 18))),
    ]),
  );
}

class _CounterButton extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap;
  const _CounterButton({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 34, height: 34,
        decoration: BoxDecoration(
            color: onTap != null ? AppColors.primary : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: onTap != null ? Colors.white : AppColors.grey, size: 18)));
}
