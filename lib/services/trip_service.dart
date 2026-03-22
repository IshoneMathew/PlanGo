import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_models.dart';

class TripService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ── Save new trip (caches user info for admin view) ───────────
  static Future<String> saveTrip(BookedTrip trip) async {
    // Fetch user display info to cache in trip doc
    String? name, email;
    try {
      final user = _auth.currentUser;
      name  = user?.displayName ?? '';
      email = user?.email ?? '';
      // Also try Firestore profile for name
      if (name.isEmpty) {
        final doc = await _db.collection('users').doc(user?.uid).get();
        name = doc.data()?['name'] ?? '';
      }
    } catch (_) {}

    final data = trip.toMap()
      ..['userName']  = name
      ..['userEmail'] = email;

    final ref = await _db.collection('trips').add(data);
    return ref.id;
  }

  // ── Stream: current user's trips (sorted client-side) ─────────
  static Stream<List<BookedTrip>> userTripsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('trips')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final trips = snap.docs.map((d) => BookedTrip.fromMap(d.id, d.data())).toList();
          trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return trips;
        });
  }

  // ── Stream: ALL trips (admin view) ────────────────────────────
  static Stream<List<BookedTrip>> allTripsStream() {
    return _db
        .collection('trips')
        .snapshots()
        .map((snap) {
          final trips = snap.docs.map((d) => BookedTrip.fromMap(d.id, d.data())).toList();
          trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return trips;
        });
  }

  // ── Admin: confirm trip (assign driver, mark confirmed) ────────
  static Future<void> confirmTrip({
    required String tripId,
    required Driver driver,
    String? transportMode,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'status': 'confirmed',
      'assignedDriver': driver.toMap(),
      if (transportMode != null) 'transportMode': transportMode,
      'pendingOffer': null,
    });
  }

  // ── Admin: send offer (modified trip details) ─────────────────
  static Future<void> sendOffer({
    required String tripId,
    required String message,
    double? newTotalCost,
    String? newTransportMode,
    Driver? assignedDriver,
  }) async {
    final offer = AdminOffer(
      message: message,
      newTotalCost: newTotalCost,
      newTransportMode: newTransportMode,
      assignedDriver: assignedDriver,
      sentAt: DateTime.now(),
      offerStatus: 'pending',
    );
    await _db.collection('trips').doc(tripId).update({
      'status': 'pending_offer',
      'pendingOffer': offer.toMap(),
    });
  }

  // ── User: accept offer ────────────────────────────────────────
  static Future<void> acceptOffer(String tripId) async {
    final doc = await _db.collection('trips').doc(tripId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final offer = data['pendingOffer'] as Map<String, dynamic>?;
    if (offer == null) return;

    final updates = <String, dynamic>{
      'status': 'confirmed',
      'pendingOffer': {...offer, 'offerStatus': 'accepted'},
    };
    if (offer['newTotalCost'] != null) updates['totalCost'] = offer['newTotalCost'];
    if (offer['newTransportMode'] != null) updates['transportMode'] = offer['newTransportMode'];
    if (offer['assignedDriver'] != null) updates['assignedDriver'] = offer['assignedDriver'];

    await _db.collection('trips').doc(tripId).update(updates);
  }

  // ── User: decline offer ───────────────────────────────────────
  static Future<void> declineOffer(String tripId) async {
    final doc = await _db.collection('trips').doc(tripId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final offer = data['pendingOffer'] as Map<String, dynamic>?;
    if (offer == null) return;
    await _db.collection('trips').doc(tripId).update({
      'status': 'upcoming',
      'pendingOffer': {...offer, 'offerStatus': 'declined'},
    });
  }

  // ── Update transport / hotel ──────────────────────────────────
  static Future<void> updateTransport(String tripId, String mode) async {
    await _db.collection('trips').doc(tripId).update({'transportMode': mode});
  }

  static Future<void> updateDayHotel(String tripId, int day, Hotel hotel) async {
    final doc = await _db.collection('trips').doc(tripId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final itinerary = List<Map<String, dynamic>>.from(data['itinerary'] ?? []);
    for (int i = 0; i < itinerary.length; i++) {
      if ((itinerary[i]['day'] as int?) == day) {
        itinerary[i] = {...itinerary[i], 'selectedHotel': hotel.toMap()};
        break;
      }
    }
    await _db.collection('trips').doc(tripId).update({'itinerary': itinerary});
  }

  // ── Cancel / Delete ───────────────────────────────────────────
  static Future<void> cancelTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).update({'status': 'cancelled'});
  }

  static Future<void> deleteTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).delete();
  }
}
