import '../models/trip_models.dart';

class DriversData {
  static const List<Driver> drivers = [
    Driver(
      id: 'd1', name: 'Kasun Perera',
      phone: '+94 77 123 4567', vehicleType: 'Toyota HiAce Van',
      vehiclePlate: 'WP CAB-1234',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
      rating: 4.9, available: true,
    ),
    Driver(
      id: 'd2', name: 'Nimal Silva',
      phone: '+94 71 234 5678', vehicleType: 'Toyota Land Cruiser',
      vehiclePlate: 'WP KA-5678',
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
      rating: 4.8, available: true,
    ),
    Driver(
      id: 'd3', name: 'Roshan Fernando',
      phone: '+94 76 345 6789', vehicleType: 'KIA Carnival',
      vehiclePlate: 'WP PA-9012',
      photoUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&q=80',
      rating: 4.7, available: true,
    ),
    Driver(
      id: 'd4', name: 'Suresh Bandara',
      phone: '+94 75 456 7890', vehicleType: 'Toyota Prius (AC)',
      vehiclePlate: 'SP BA-3456',
      photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
      rating: 4.6, available: false,
    ),
    Driver(
      id: 'd5', name: 'Chamara Rajapaksa',
      phone: '+94 70 567 8901', vehicleType: 'Tuk-Tuk (3-Wheeler)',
      vehiclePlate: 'SG TUK-789',
      photoUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&q=80',
      rating: 4.5, available: true,
    ),
    Driver(
      id: 'd6', name: 'Thilan Wijesinghe',
      phone: '+94 72 678 9012', vehicleType: 'Luxury Mercedes V-Class',
      vehiclePlate: 'WP MB-0123',
      photoUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=100&q=80',
      rating: 5.0, available: true,
    ),
  ];

  static List<Driver> get availableDrivers => drivers.where((d) => d.available).toList();
}
