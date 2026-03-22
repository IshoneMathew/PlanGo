class Destination {
  final String id;
  final String name;
  final String location;
  final String province;
  final double rating;
  final int reviews;
  final double pricePerPerson;
  final String imageUrl;
  final String description;
  final List<String> galleryImages;
  final int travelers;
  bool isFavorite;
  bool isBookmarked;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.province,
    required this.rating,
    required this.reviews,
    required this.pricePerPerson,
    required this.imageUrl,
    required this.description,
    required this.galleryImages,
    required this.travelers,
    this.isFavorite = false,
    this.isBookmarked = false,
  });
}

class TripSchedule {
  final String id;
  final String destinationName;
  final String location;
  final String imageUrl;
  final DateTime date;
  final String time;

  TripSchedule({
    required this.id,
    required this.destinationName,
    required this.location,
    required this.imageUrl,
    required this.date,
    required this.time,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.senderAvatar,
  });
}

class Contact {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool isOnline;

  Contact({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String avatar;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.avatar,
    this.isRead = false,
  });
}
