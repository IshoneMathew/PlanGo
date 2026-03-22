import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/models.dart';

// ── Admin emails ─────────────────────────────────────────────────
const List<String> kAdminEmails = [
  'ishone2002@gmail.com',
  'admin@plango.lk',
];

class FirebaseService {
  static final _auth    = FirebaseAuth.instance;
  static final _db      = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static bool get isAdmin {
    final email = currentUser?.email?.toLowerCase().trim() ?? '';
    return kAdminEmails.map((e) => e.toLowerCase()).contains(email);
  }

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  static Future<UserCredential> signUp(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email.trim().toLowerCase(),
      'isAdmin': kAdminEmails.map((e) => e.toLowerCase()).contains(email.trim().toLowerCase()),
      'createdAt': FieldValue.serverTimestamp(),
      'rewardPoints': 0,
      'travelTrips': 0,
      'bucketList': 0,
    });
    return cred;
  }

  static Future<void> signOut() => _auth.signOut();
  static Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) { return null; }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update(data);
    if (data.containsKey('name')) {
      await currentUser?.updateDisplayName(data['name']);
    }
  }

  static Stream<List<Destination>> destinationsStream() {
    return _db
        .collection('destinations')
        .orderBy('order', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _destFromDoc(d)).toList());
  }

  static Future<List<Destination>> fetchDestinations() async {
    final snap = await _db.collection('destinations').orderBy('order').get();
    return snap.docs.map((d) => _destFromDoc(d)).toList();
  }

  static Destination _destFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Destination(
      id: doc.id,
      name: d['name'] ?? '',
      location: d['location'] ?? '',
      province: d['province'] ?? '',
      rating: (d['rating'] ?? 4.5).toDouble(),
      reviews: (d['reviews'] ?? 0).toInt(),
      pricePerPerson: (d['pricePerPerson'] ?? 0).toDouble(),
      imageUrl: d['imageUrl'] ?? '',
      description: d['description'] ?? '',
      galleryImages: List<String>.from(d['galleryImages'] ?? []),
      travelers: (d['travelers'] ?? 0).toInt(),
      isFavorite: d['isFavorite'] ?? false,
      isBookmarked: d['isBookmarked'] ?? false,
    );
  }

  static Future<void> addDestination(Map<String, dynamic> data) async {
    final count = (await _db.collection('destinations').count().get()).count ?? 0;
    await _db.collection('destinations').add({
      ...data, 'order': count,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    await _db.collection('destinations').doc(id).update({
      ...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> deleteDestination(String id) async {
    await _db.collection('destinations').doc(id).delete();
  }

  static Future<String> uploadDestinationImage(File file, String destId) async {
    final ref = _storage.ref()
        .child('destinations/$destId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  static Future<void> deleteImage(String url) async {
    try { await _storage.refFromURL(url).delete(); } catch (_) {}
  }

  static Future<void> seedDestinationsIfEmpty() async {
    final snap = await _db.collection('destinations').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final batch = _db.batch();
    final defaults = _defaultDestinations();
    for (int i = 0; i < defaults.length; i++) {
      final ref = _db.collection('destinations').doc();
      batch.set(ref, {...defaults[i], 'order': i, 'createdAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  static List<Map<String, dynamic>> _defaultDestinations() => [
    {'name':'Sigiriya Rock Fortress','location':'Sigiriya, Matale District','province':'Central Province','rating':4.9,'reviews':4821,'pricePerPerson':59.0,'imageUrl':'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=800&q=80','description':'Sigiriya is an ancient rock fortress rising 200m above the surrounding jungle in Sri Lanka\'s Cultural Triangle. A UNESCO World Heritage Site.','galleryImages':['https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80','https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&q=80'],'travelers':50,'isFavorite':false,'isBookmarked':true},
    {'name':'Mirissa Beach','location':'Mirissa, Matara District','province':'Southern Province','rating':4.7,'reviews':3102,'pricePerPerson':35.0,'imageUrl':'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80','description':'Mirissa is Sri Lanka\'s premier beach destination, famous for whale watching between November and April.','galleryImages':['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'],'travelers':35,'isFavorite':true,'isBookmarked':false},
    {'name':'Temple of the Tooth','location':'Kandy, Kandy District','province':'Central Province','rating':4.8,'reviews':5240,'pricePerPerson':25.0,'imageUrl':'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80','description':'Sri Lanka\'s most sacred Buddhist site, the Temple of the Tooth Relic houses a tooth of the Buddha.','galleryImages':['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'],'travelers':45,'isFavorite':true,'isBookmarked':true},
    {'name':'Galle Fort','location':'Galle, Galle District','province':'Southern Province','rating':4.8,'reviews':3987,'pricePerPerson':20.0,'imageUrl':'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80','description':'Built by the Portuguese in 1588, Galle Fort is the largest remaining European fortress in Asia.','galleryImages':['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'],'travelers':40,'isFavorite':true,'isBookmarked':false},
    {'name':'Ella Rock & Nine Arches','location':'Ella, Badulla District','province':'Uva Province','rating':4.8,'reviews':2876,'pricePerPerson':30.0,'imageUrl':'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80','description':'Ella is famous for its Nine Arch Bridge surrounded by tea plantations.','galleryImages':['https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'],'travelers':28,'isFavorite':true,'isBookmarked':false},
    {'name':'Yala National Park','location':'Yala, Hambantota District','province':'Southern Province','rating':4.7,'reviews':2341,'pricePerPerson':75.0,'imageUrl':'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=800&q=80','description':'Yala is Sri Lanka\'s most visited national park, home to the world\'s highest density of leopards.','galleryImages':['https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80'],'travelers':22,'isFavorite':false,'isBookmarked':false},
    {'name':'Arugam Bay','location':'Arugam Bay, Ampara District','province':'Eastern Province','rating':4.6,'reviews':1893,'pricePerPerson':40.0,'imageUrl':'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80','description':'One of the world\'s top ten surf spots, drawing wave-riders from around the globe.','galleryImages':['https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'],'travelers':18,'isFavorite':true,'isBookmarked':false},
    {'name':'Dambulla Cave Temple','location':'Dambulla, Matale District','province':'Central Province','rating':4.7,'reviews':3124,'pricePerPerson':22.0,'imageUrl':'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80','description':'Sri Lanka\'s largest and best-preserved cave temple complex, dating back to the 1st century BC.','galleryImages':['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'],'travelers':15,'isFavorite':false,'isBookmarked':false},
  ];
}
