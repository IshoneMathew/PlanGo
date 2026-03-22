import '../models/trip_models.dart';

class TourGuidesData {
  static const List<TourGuide> guides = [
    TourGuide(
      id: 'g1',
      name: 'Nuwan Perera',
      bio: '12 years guiding experience across the Cultural Triangle. Expert in Sigiriya, Dambulla, Polonnaruwa and Anuradhapura. Trained archaeologist with deep knowledge of ancient Sri Lankan history.',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      rating: 4.9,
      tours: 847,
      pricePerDay: 45,
      languages: ['English', 'Sinhala', 'Tamil', 'German'],
      specialties: ['Cultural Triangle', 'Archaeology', 'History', 'Photography'],
      available: true,
    ),
    TourGuide(
      id: 'g2',
      name: 'Priya Jayasuriya',
      bio: 'Certified wildlife biologist and safari guide specialising in Yala and Wilpattu National Parks. Known for incredible leopard sightings. She has a special gift for spotting wildlife others miss.',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      rating: 4.8,
      tours: 612,
      pricePerDay: 55,
      languages: ['English', 'Sinhala', 'French'],
      specialties: ['Wildlife Safari', 'Bird Watching', 'Nature', 'Photography'],
      available: true,
    ),
    TourGuide(
      id: 'g3',
      name: 'Chaminda Silva',
      bio: 'Southern coast specialist — Galle, Mirissa, Hikkaduwa. Expert whale watching guide with 9 years on Mirissa boats. Also runs cooking classes featuring authentic southern Sri Lankan cuisine.',
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      rating: 4.7,
      tours: 534,
      pricePerDay: 40,
      languages: ['English', 'Sinhala', 'Japanese'],
      specialties: ['Whale Watching', 'Beach', 'Surfing', 'Local Food'],
      available: true,
    ),
    TourGuide(
      id: 'g4',
      name: 'Amaya Fernando',
      bio: 'Hill Country and tea estates specialist. Knows every trail in the Ella and Nuwara Eliya region. Has hiked every peak in Sri Lanka\'s central mountains and loves sharing hidden waterfalls.',
      photoUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
      rating: 4.8,
      tours: 421,
      pricePerDay: 42,
      languages: ['English', 'Sinhala', 'Italian'],
      specialties: ['Trekking', 'Tea Estates', 'Hill Country', 'Waterfalls'],
      available: true,
    ),
    TourGuide(
      id: 'g5',
      name: 'Ruwan Bandara',
      bio: 'Full-island tour specialist with a luxury 4WD. Handles custom multi-week itineraries for high-end clients. Former Colombo Five-Star concierge with exceptional hospitality standards.',
      photoUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200&q=80',
      rating: 4.9,
      tours: 1023,
      pricePerDay: 80,
      languages: ['English', 'Sinhala', 'Arabic', 'Chinese'],
      specialties: ['Luxury Tours', 'Full Island', 'VIP Transfers', 'Honeymoon'],
      available: false, // currently booked
    ),
    TourGuide(
      id: 'g6',
      name: 'Dilini Wickramasinghe',
      bio: 'Colombo city expert and cultural ambassador. Runs immersive street food tours, colonial history walks, and Buddhist temple experiences in Colombo. Perfect for first-time visitors.',
      photoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      rating: 4.6,
      tours: 288,
      pricePerDay: 35,
      languages: ['English', 'Sinhala', 'Hindi'],
      specialties: ['City Tours', 'Street Food', 'Buddhism', 'Architecture'],
      available: true,
    ),
  ];

  static List<TourGuide> get availableGuides =>
      guides.where((g) => g.available).toList();
}
