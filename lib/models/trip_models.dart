// ─── Hotel ────────────────────────────────────────────────────────
class Hotel {
  final String id, name, location, city, imageUrl, category, description;
  final double pricePerNight, rating;
  final int reviews;
  final List<String> amenities;
  final bool freeCancellation;

  const Hotel({
    required this.id, required this.name, required this.location,
    required this.city, required this.pricePerNight, required this.rating,
    required this.reviews, required this.imageUrl, required this.amenities,
    required this.freeCancellation, required this.category, required this.description,
  });

  factory Hotel.fromMap(Map<String, dynamic> m) => Hotel(
    id: m['id'] ?? '', name: m['name'] ?? '', location: m['location'] ?? '',
    city: m['city'] ?? '', pricePerNight: (m['pricePerNight'] ?? 0).toDouble(),
    rating: (m['rating'] ?? 4.0).toDouble(), reviews: (m['reviews'] ?? 0).toInt(),
    imageUrl: m['imageUrl'] ?? '', amenities: List<String>.from(m['amenities'] ?? []),
    freeCancellation: m['freeCancellation'] ?? false,
    category: m['category'] ?? 'midrange', description: m['description'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'location': location, 'city': city,
    'pricePerNight': pricePerNight, 'rating': rating, 'reviews': reviews,
    'imageUrl': imageUrl, 'amenities': amenities,
    'freeCancellation': freeCancellation, 'category': category, 'description': description,
  };
}

// ─── Tour Guide ───────────────────────────────────────────────────
class TourGuide {
  final String id, name, bio, photoUrl;
  final double rating, pricePerDay;
  final int tours;
  final List<String> languages, specialties;
  final bool available;

  const TourGuide({
    required this.id, required this.name, required this.bio,
    required this.photoUrl, required this.rating, required this.tours,
    required this.pricePerDay, required this.languages,
    required this.specialties, required this.available,
  });
}

// ─── Driver ───────────────────────────────────────────────────────
class Driver {
  final String id, name, phone, vehicleType, vehiclePlate, photoUrl;
  final double rating;
  final bool available;

  const Driver({
    required this.id, required this.name, required this.phone,
    required this.vehicleType, required this.vehiclePlate,
    required this.photoUrl, required this.rating, required this.available,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'vehicleType': vehicleType, 'vehiclePlate': vehiclePlate,
    'photoUrl': photoUrl, 'rating': rating,
  };

  factory Driver.fromMap(Map<String, dynamic> m) => Driver(
    id: m['id'] ?? '', name: m['name'] ?? '', phone: m['phone'] ?? '',
    vehicleType: m['vehicleType'] ?? 'Car', vehiclePlate: m['vehiclePlate'] ?? '',
    photoUrl: m['photoUrl'] ?? '', rating: (m['rating'] ?? 4.5).toDouble(),
    available: m['available'] ?? true,
  );
}

// ─── Admin Offer (sent when admin modifies a trip) ────────────────
class AdminOffer {
  final String message;
  final double? newTotalCost;
  final String? newTransportMode;
  final Driver? assignedDriver;
  final DateTime sentAt;
  // 'pending' | 'accepted' | 'declined'
  final String offerStatus;

  const AdminOffer({
    required this.message, this.newTotalCost, this.newTransportMode,
    this.assignedDriver, required this.sentAt, required this.offerStatus,
  });

  Map<String, dynamic> toMap() => {
    'message': message,
    'newTotalCost': newTotalCost,
    'newTransportMode': newTransportMode,
    'assignedDriver': assignedDriver?.toMap(),
    'sentAt': sentAt.toIso8601String(),
    'offerStatus': offerStatus,
  };

  factory AdminOffer.fromMap(Map<String, dynamic> m) => AdminOffer(
    message: m['message'] ?? '',
    newTotalCost: m['newTotalCost'] != null ? (m['newTotalCost'] as num).toDouble() : null,
    newTransportMode: m['newTransportMode'],
    assignedDriver: m['assignedDriver'] != null ? Driver.fromMap(m['assignedDriver']) : null,
    sentAt: DateTime.tryParse(m['sentAt'] ?? '') ?? DateTime.now(),
    offerStatus: m['offerStatus'] ?? 'pending',
  );
}

// ─── Booked Trip ──────────────────────────────────────────────────
class BookedTrip {
  final String id, userId, destination, transportMode;
  final int days;
  final double budget, totalCost;
  final List<String> interests;
  final List<DayItinerary> itinerary;
  final TourGuide? tourGuide;
  final Driver? assignedDriver;
  final AdminOffer? pendingOffer;
  final DateTime createdAt;
  // 'upcoming' | 'confirmed' | 'completed' | 'cancelled' | 'pending_offer'
  final String status;
  // user's display name cached for admin view
  final String? userName;
  final String? userEmail;

  const BookedTrip({
    required this.id, required this.userId, required this.destination,
    required this.days, required this.budget, required this.totalCost,
    required this.interests, required this.itinerary,
    required this.transportMode, this.tourGuide, this.assignedDriver,
    this.pendingOffer, required this.createdAt, required this.status,
    this.userName, this.userEmail,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'destination': destination,
    'days': days,
    'budget': budget,
    'totalCost': totalCost,
    'interests': interests,
    'itinerary': itinerary.map((d) => d.toMap()).toList(),
    'transportMode': transportMode,
    'tourGuide': tourGuide != null ? {
      'id': tourGuide!.id, 'name': tourGuide!.name,
      'pricePerDay': tourGuide!.pricePerDay, 'photoUrl': tourGuide!.photoUrl,
    } : null,
    'assignedDriver': assignedDriver?.toMap(),
    'pendingOffer': pendingOffer?.toMap(),
    'createdAt': createdAt.toIso8601String(),
    'status': status,
    'userName': userName,
    'userEmail': userEmail,
  };

  factory BookedTrip.fromMap(String id, Map<String, dynamic> m) => BookedTrip(
    id: id,
    userId: m['userId'] ?? '',
    destination: m['destination'] ?? '',
    days: (m['days'] ?? 1).toInt(),
    budget: (m['budget'] ?? 0).toDouble(),
    totalCost: (m['totalCost'] ?? 0).toDouble(),
    interests: List<String>.from(m['interests'] ?? []),
    itinerary: (m['itinerary'] as List? ?? []).map((d) => DayItinerary.fromMap(d)).toList(),
    transportMode: m['transportMode'] ?? 'car',
    tourGuide: m['tourGuide'] != null ? _tourGuideFromMap(m['tourGuide']) : null,
    assignedDriver: m['assignedDriver'] != null ? Driver.fromMap(m['assignedDriver']) : null,
    pendingOffer: m['pendingOffer'] != null ? AdminOffer.fromMap(m['pendingOffer']) : null,
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
    status: m['status'] ?? 'upcoming',
    userName: m['userName'],
    userEmail: m['userEmail'],
  );

  static TourGuide _tourGuideFromMap(Map<String, dynamic> m) => TourGuide(
    id: m['id'] ?? '', name: m['name'] ?? '', bio: '',
    photoUrl: m['photoUrl'] ?? '', rating: (m['rating'] ?? 4.5).toDouble(),
    tours: 0, pricePerDay: (m['pricePerDay'] ?? 0).toDouble(),
    languages: [], specialties: [], available: true,
  );

  BookedTrip copyWith({
    String? status, Driver? assignedDriver,
    AdminOffer? pendingOffer, double? totalCost, String? transportMode,
  }) => BookedTrip(
    id: id, userId: userId, destination: destination, days: days,
    budget: budget, totalCost: totalCost ?? this.totalCost,
    interests: interests, itinerary: itinerary,
    transportMode: transportMode ?? this.transportMode,
    tourGuide: tourGuide,
    assignedDriver: assignedDriver ?? this.assignedDriver,
    pendingOffer: pendingOffer ?? this.pendingOffer,
    createdAt: createdAt, status: status ?? this.status,
    userName: userName, userEmail: userEmail,
  );
}

// ─── Day Itinerary ────────────────────────────────────────────────
class DayItinerary {
  final int day;
  final List<String> activities;
  final String lastStop, imageUrl;
  Hotel? selectedHotel;

  DayItinerary({
    required this.day, required this.activities,
    required this.lastStop, required this.imageUrl, this.selectedHotel,
  });

  Map<String, dynamic> toMap() => {
    'day': day, 'activities': activities,
    'lastStop': lastStop, 'imageUrl': imageUrl,
    'selectedHotel': selectedHotel?.toMap(),
  };

  factory DayItinerary.fromMap(Map<String, dynamic> m) => DayItinerary(
    day: (m['day'] ?? 1).toInt(),
    activities: List<String>.from(m['activities'] ?? []),
    lastStop: m['lastStop'] ?? '', imageUrl: m['imageUrl'] ?? '',
    selectedHotel: m['selectedHotel'] != null ? Hotel.fromMap(m['selectedHotel']) : null,
  );
}
