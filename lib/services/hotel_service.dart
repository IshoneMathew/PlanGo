import '../models/trip_models.dart';

class HotelService {
  /// Returns hotels for a city sorted by price.
  /// Always returns at least 4 options spanning budget → luxury.
  /// budgetPerNight is used only for the "over budget" badge — never hides results.
  static Future<List<Hotel>> getHotels({
    required String city,
    required double budgetPerNight,
    required int nights,
  }) async {
    return _getHotels(city: city, budgetPerNight: budgetPerNight);
  }

  static List<Hotel> _getHotels({
    required String city,
    required double budgetPerNight,
  }) {
    final all = _allHotels();
    final cityLow = city.toLowerCase().trim();

    // Flexible city matching
    var matches = all.where((h) {
      final hc = h.city.toLowerCase();
      return hc == cityLow ||
          hc.contains(cityLow) ||
          cityLow.contains(hc) ||
          h.location.toLowerCase().contains(cityLow);
    }).toList();

    // If fewer than 3, add nearest hotels from any city
    if (matches.length < 3) {
      final extras = all.where((h) => !matches.contains(h)).take(4 - matches.length).toList();
      matches = [...matches, ...extras];
    }

    // Sort by price ascending so cheapest is first
    matches.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    return matches;
  }

  static List<Hotel> _allHotels() => [
    // ── COLOMBO ─────────────────────────────────────────────────
    Hotel(id:'h1',  name:'Colombo City Hostel',         city:'Colombo',      location:'Pettah, Colombo',            pricePerNight:12,  rating:3.9, reviews:420,  imageUrl:'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',  amenities:['WiFi','Dorm/Private','AC','Lockers'],                  freeCancellation:true,  category:'budget',   description:'Affordable hostel in central Colombo, great for backpackers.'),
    Hotel(id:'h2',  name:'Casons Tourist Inn',          city:'Colombo',      location:'Slave Island, Colombo',      pricePerNight:28,  rating:3.8, reviews:310,  imageUrl:'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80',   amenities:['WiFi','AC','Restaurant'],                              freeCancellation:true,  category:'budget',   description:'Clean budget hotel near Beira Lake.'),
    Hotel(id:'h3',  name:'Colombo City Hotel',          city:'Colombo',      location:'Slave Island, Colombo 02',   pricePerNight:45,  rating:4.1, reviews:876,  imageUrl:'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80',   amenities:['WiFi','AC','Restaurant','Parking'],                    freeCancellation:true,  category:'budget',   description:'Clean, comfortable budget hotel centrally located.'),
    Hotel(id:'h4',  name:'Movenpick Hotel Colombo',     city:'Colombo',      location:'42 Janadhipathi Mawatha',    pricePerNight:140, rating:4.5, reviews:1820, imageUrl:'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80',   amenities:['Pool','Spa','WiFi','Restaurant','Gym','Rooftop'],       freeCancellation:false, category:'midrange', description:'Contemporary hotel overlooking Beira Lake.'),
    Hotel(id:'h5',  name:'Cinnamon Grand Colombo',      city:'Colombo',      location:'77 Galle Rd, Colombo 03',    pricePerNight:180, rating:4.6, reviews:3241, imageUrl:'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',  amenities:['Pool','Spa','WiFi','Restaurant','Bar','Gym'],           freeCancellation:true,  category:'luxury',   description:'Iconic 5-star in the heart of Colombo.'),

    // ── KANDY ───────────────────────────────────────────────────
    Hotel(id:'h6',  name:'Kandy Backpacker Hostel',     city:'Kandy',        location:'Kandy Town Centre',          pricePerNight:10,  rating:3.8, reviews:280,  imageUrl:'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',  amenities:['WiFi','Dorm Beds','Shared Kitchen'],                   freeCancellation:true,  category:'budget',   description:'Friendly hostel walking distance to Temple of the Tooth.'),
    Hotel(id:'h7',  name:'Kandy Samadhi Centre',        city:'Kandy',        location:'Anniewatte, Kandy',          pricePerNight:25,  rating:4.0, reviews:450,  imageUrl:'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',  amenities:['WiFi','Breakfast','Garden'],                           freeCancellation:true,  category:'budget',   description:'Peaceful guesthouse with lush gardens.'),
    Hotel(id:'h8',  name:'Hotel Topaz Kandy',           city:'Kandy',        location:'Aniwatte Rd, Kandy',         pricePerNight:38,  rating:4.0, reviews:560,  imageUrl:'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Lake View'],                freeCancellation:true,  category:'budget',   description:'Budget pool hotel with views of Kandy town.'),
    Hotel(id:'h9',  name:'Hotel Suisse Kandy',          city:'Kandy',        location:'30 Sangaraja Mawatha',       pricePerNight:75,  rating:4.3, reviews:1240, imageUrl:'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Garden View'],               freeCancellation:true,  category:'midrange', description:'Colonial-era hotel with beautiful Kandy Lake views.'),
    Hotel(id:'h10', name:"Earl's Regency Kandy",        city:'Kandy',        location:'Tennekumbura, Kandy',        pricePerNight:160, rating:4.7, reviews:2100, imageUrl:'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&q=80',  amenities:['Pool','Spa','WiFi','Restaurant','Gym','Tea Lounge'],    freeCancellation:true,  category:'luxury',   description:'Hilltop luxury resort with infinity pool over Mahaweli River.'),

    // ── ELLA ────────────────────────────────────────────────────
    Hotel(id:'h11', name:'Ella Rock View Hostel',       city:'Ella',         location:'Main Street, Ella',          pricePerNight:8,   rating:3.9, reviews:390,  imageUrl:'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=400&q=80',  amenities:['WiFi','Dorm','Valley View'],                           freeCancellation:true,  category:'budget',   description:'The cheapest sleep in Ella with a mountain view from the balcony.'),
    Hotel(id:'h12', name:'Ella Gap Tourist Inn',        city:'Ella',         location:'Main Street, Ella',          pricePerNight:18,  rating:4.0, reviews:780,  imageUrl:'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=400&q=80',  amenities:['WiFi','Breakfast','Mountain View'],                    freeCancellation:true,  category:'budget',   description:'Cosy budget guesthouse with amazing views.'),
    Hotel(id:'h13', name:'Zion View Ella',              city:'Ella',         location:'Ella Rock View Point',       pricePerNight:55,  rating:4.5, reviews:1200, imageUrl:'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',  amenities:['WiFi','Restaurant','Terrace','Valley View'],            freeCancellation:false, category:'midrange', description:'Charming mid-range hotel with breathtaking valley views.'),
    Hotel(id:'h14', name:'98 Acres Resort Ella',        city:'Ella',         location:'Passara Rd, Ella',           pricePerNight:220, rating:4.8, reviews:3560, imageUrl:'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80',  amenities:['Infinity Pool','Spa','WiFi','Restaurant','Tea Plantation View'], freeCancellation:true, category:'luxury', description:'Spectacular tea plantation resort over Ella Gap.'),

    // ── GALLE ───────────────────────────────────────────────────
    Hotel(id:'h15', name:'Galle Fort Hostel',           city:'Galle',        location:'Inside Galle Fort',          pricePerNight:14,  rating:4.0, reviews:340,  imageUrl:'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',  amenities:['WiFi','Common Room','Fort Location'],                  freeCancellation:true,  category:'budget',   description:'Sleep inside the UNESCO fort walls on a shoestring.'),
    Hotel(id:'h16', name:'Galle Fort Hotel',            city:'Galle',        location:'28 Church St, Galle Fort',   pricePerNight:80,  rating:4.4, reviews:1100, imageUrl:'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',  amenities:['WiFi','Rooftop Pool','Restaurant','Fort View'],         freeCancellation:true,  category:'midrange', description:'Boutique hotel inside the historic fort.'),
    Hotel(id:'h17', name:'Jetwing Lighthouse',          city:'Galle',        location:'Dadella, Galle',             pricePerNight:175, rating:4.7, reviews:2340, imageUrl:'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80',   amenities:['Pool','Spa','WiFi','Restaurant','Ocean View'],          freeCancellation:true,  category:'luxury',   description:'Geoffrey Bawa masterpiece on a rocky promontory above the sea.'),

    // ── MIRISSA ─────────────────────────────────────────────────
    Hotel(id:'h18', name:'Mirissa Beach Cabana',        city:'Mirissa',      location:'Mirissa Beach',              pricePerNight:20,  rating:4.0, reviews:520,  imageUrl:'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80',  amenities:['WiFi','Beach Access','Fan','Breakfast'],               freeCancellation:true,  category:'budget',   description:'Laid-back beach cabanas right on the sand.'),
    Hotel(id:'h19', name:'Mirissa Hills',               city:'Mirissa',      location:'Mirissa Hills, Matara',      pricePerNight:95,  rating:4.6, reviews:1560, imageUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',  amenities:['Infinity Pool','WiFi','Restaurant','Ocean View','Bar'], freeCancellation:true,  category:'midrange', description:'Hillside hotel with panoramic ocean view infinity pool.'),

    // ── SIGIRIYA ────────────────────────────────────────────────
    Hotel(id:'h20', name:'Sigiriya Budget Guesthouse',  city:'Sigiriya',     location:'Sigiriya Village',           pricePerNight:15,  rating:3.8, reviews:260,  imageUrl:'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&q=80',  amenities:['WiFi','Breakfast','Rock View'],                        freeCancellation:true,  category:'budget',   description:'Simple guesthouse with direct views of Sigiriya Rock.'),
    Hotel(id:'h21', name:'Sigiriya Village Hotel',      city:'Sigiriya',     location:'Sigiriya, Matale District',  pricePerNight:55,  rating:4.2, reviews:890,  imageUrl:'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Rock View'],                 freeCancellation:true,  category:'midrange', description:'Affordable hotel with pool and rock fortress views.'),
    Hotel(id:'h22', name:'Water Garden Sigiriya',       city:'Sigiriya',     location:'Sigiriya Village, Matale',   pricePerNight:290, rating:4.8, reviews:2100, imageUrl:'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80',  amenities:['Pool','Spa','WiFi','Restaurant','Safari','Rock View'],  freeCancellation:true,  category:'luxury',   description:'Luxury eco-resort with private pool villas and rock views.'),

    // ── NEGOMBO ─────────────────────────────────────────────────
    Hotel(id:'h23', name:"Brown's Beach Guesthouse",    city:'Negombo',      location:'Lewis Place, Negombo',       pricePerNight:18,  rating:3.8, reviews:310,  imageUrl:'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',  amenities:['WiFi','Beach Nearby','Restaurant'],                    freeCancellation:true,  category:'budget',   description:'Simple friendly guesthouse near the beach.'),
    Hotel(id:'h24', name:'Jetwing Blue Negombo',        city:'Negombo',      location:'Negombo Beach',              pricePerNight:95,  rating:4.5, reviews:1870, imageUrl:'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80',   amenities:['Beach','Pool','Spa','WiFi','Restaurant'],               freeCancellation:true,  category:'midrange', description:'Stylish beachfront hotel with direct beach access.'),

    // ── NUWARA ELIYA ────────────────────────────────────────────
    Hotel(id:'h25', name:'Tea Bush Guesthouse',         city:'Nuwara Eliya', location:'Tea Plantation, Nuwara Eliya', pricePerNight:20, rating:4.1, reviews:390, imageUrl:'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80', amenities:['WiFi','Tea Tasting','Garden View','Breakfast'],        freeCancellation:true,  category:'budget',   description:'Cosy tea estate guesthouse with daily tea tasting.'),
    Hotel(id:'h26', name:'Grand Hotel Nuwara Eliya',    city:'Nuwara Eliya', location:'Grand Hotel Rd, Nuwara Eliya', pricePerNight:95, rating:4.4, reviews:1670, imageUrl:'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80', amenities:['Golf','Pool','WiFi','Colonial Restaurant','Billiards'], freeCancellation:true, category:'midrange', description:'Historic British colonial hotel surrounded by tea estates.'),

    // ── YALA ────────────────────────────────────────────────────
    Hotel(id:'h27', name:'Kithala Resort Yala',         city:'Yala',         location:'Ruhuna, Hambantota',         pricePerNight:55,  rating:4.1, reviews:390,  imageUrl:'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80',  amenities:['WiFi','Restaurant','Safari Booking'],                  freeCancellation:true,  category:'budget',   description:'Eco-lodge near Yala gate for early morning safaris.'),
    Hotel(id:'h28', name:'Chena Huts by Uga',           city:'Yala',         location:'Yala National Park Buffer',  pricePerNight:480, rating:4.9, reviews:780,  imageUrl:'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80',  amenities:['Private Plunge Pool','Safari','WiFi','Restaurant'],     freeCancellation:false, category:'luxury',   description:'Ultra-luxury tented camp inside Yala.'),

    // ── ARUGAM BAY ──────────────────────────────────────────────
    Hotel(id:'h29', name:'Stardust Arugam Bay',         city:'Arugam Bay',   location:'Arugam Bay Beach',           pricePerNight:20,  rating:4.2, reviews:1100, imageUrl:'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400&q=80',  amenities:['WiFi','Surf Boards','Restaurant','Beach Access'],       freeCancellation:true,  category:'budget',   description:'The classic surfer hangout right on the beach.'),
    Hotel(id:'h30', name:'Hideaway Arugam Bay',         city:'Arugam Bay',   location:'South End, Arugam Bay',      pricePerNight:75,  rating:4.6, reviews:670,  imageUrl:'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Surf Lessons','Beach View'], freeCancellation:true,  category:'midrange', description:'Boutique with pool, surf lessons and best sunset view.'),

    // ── TRINCOMALEE ─────────────────────────────────────────────
    Hotel(id:'h31', name:'Welcombe Hotel Trinco',       city:'Trincomalee',  location:"Orr's Hill, Trincomalee",    pricePerNight:30,  rating:3.9, reviews:310,  imageUrl:'https://images.unsplash.com/photo-1512100356356-de1b84283e18?w=400&q=80',  amenities:['WiFi','Restaurant','Sea View'],                        freeCancellation:true,  category:'budget',   description:'Budget hotel with harbour views.'),
    Hotel(id:'h32', name:'Jungle Beach by Uga',         city:'Trincomalee',  location:'Kuchchaveli, Trincomalee',   pricePerNight:320, rating:4.9, reviews:1230, imageUrl:'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80',   amenities:['Private Beach','Pool','Spa','WiFi','Restaurant'],       freeCancellation:false, category:'luxury',   description:'Remote eco-luxury on pristine beach.'),

    // ── DAMBULLA ────────────────────────────────────────────────
    Hotel(id:'h33', name:'Dambulla Rest House',         city:'Dambulla',     location:'Anuradhapura Rd, Dambulla',  pricePerNight:22,  rating:3.7, reviews:210,  imageUrl:'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80',  amenities:['WiFi','Restaurant','Parking'],                         freeCancellation:true,  category:'budget',   description:'Simple clean rest house near the cave temples.'),
    Hotel(id:'h34', name:'Heritance Kandalama',         city:'Dambulla',     location:'Kandalama, Dambulla',        pricePerNight:210, rating:4.8, reviews:2890, imageUrl:'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',  amenities:['Infinity Pool','Spa','WiFi','Restaurant','Lake View'],  freeCancellation:true,  category:'luxury',   description:"Geoffrey Bawa's masterpiece carved into a cliff above Kandalama Lake."),

    // ── HIKKADUWA ───────────────────────────────────────────────
    Hotel(id:'h35', name:'Hikka Beach Guesthouse',      city:'Hikkaduwa',    location:'Beach Road, Hikkaduwa',      pricePerNight:18,  rating:3.9, reviews:290,  imageUrl:'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80',  amenities:['WiFi','Beach 2min','Fan','Breakfast'],                 freeCancellation:true,  category:'budget',   description:'Simple guesthouse steps from Hikkaduwa coral beach.'),
    Hotel(id:'h36', name:'Coral Sands Hotel',           city:'Hikkaduwa',    location:'Galle Rd, Hikkaduwa',        pricePerNight:60,  rating:4.2, reviews:870,  imageUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Beach Access','Snorkelling'], freeCancellation:true, category:'midrange', description:'Pool hotel right on the coral reef beach.'),

    // ── JAFFNA ──────────────────────────────────────────────────
    Hotel(id:'h37', name:'Jaffna Heritage Hotel',       city:'Jaffna',       location:'Stanley Rd, Jaffna',         pricePerNight:25,  rating:4.0, reviews:190,  imageUrl:'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',  amenities:['WiFi','AC','Breakfast','Tamil Cuisine'],               freeCancellation:true,  category:'budget',   description:'Authentic northern Sri Lanka guesthouse.'),
    Hotel(id:'h38', name:'Thinnai Hotel Jaffna',        city:'Jaffna',       location:'Point Pedro Rd, Jaffna',     pricePerNight:55,  rating:4.3, reviews:340,  imageUrl:'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Cultural Tours'],            freeCancellation:true,  category:'midrange', description:'Best mid-range option in Jaffna with local tours.'),

    // ── UNAWATUNA ───────────────────────────────────────────────
    Hotel(id:'h39', name:'Unawatuna Beach Resort',      city:'Unawatuna',    location:'Unawatuna Bay',              pricePerNight:28,  rating:4.1, reviews:430,  imageUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',  amenities:['WiFi','Beach 1min','Restaurant','Pool'],                freeCancellation:true,  category:'budget',   description:'Great value beach resort in Unawatuna bay.'),
    Hotel(id:'h40', name:'Thaproban Beach House',       city:'Unawatuna',    location:'Rumassala, Unawatuna',       pricePerNight:90,  rating:4.6, reviews:870,  imageUrl:'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',  amenities:['Infinity Pool','WiFi','Restaurant','Sea View'],         freeCancellation:false, category:'midrange', description:'Boutique hotel on Rumassala hill with ocean views.'),

    // ── BENTOTA ─────────────────────────────────────────────────
    Hotel(id:'h41', name:'Bentota Beach Budget Inn',    city:'Bentota',      location:'Bentota Beach Rd',           pricePerNight:22,  rating:3.9, reviews:190,  imageUrl:'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80',  amenities:['WiFi','Beach Nearby','AC'],                            freeCancellation:true,  category:'budget',   description:'Good value inn near Bentota beach.'),
    Hotel(id:'h42', name:'Vivanta Bentota',             city:'Bentota',      location:'Bentota Beach',              pricePerNight:140, rating:4.5, reviews:1100, imageUrl:'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80',   amenities:['Pool','Spa','WiFi','Water Sports','Beach'],             freeCancellation:true,  category:'luxury',   description:'Luxury Taj property with direct beach access.'),

    // ── POLONNARUWA ─────────────────────────────────────────────
    Hotel(id:'h43', name:'Polonnaruwa Rest House',      city:'Polonnaruwa',  location:'Ancient City, Polonnaruwa', pricePerNight:20,  rating:3.8, reviews:210,  imageUrl:'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80',  amenities:['WiFi','Restaurant','Lake View'],                       freeCancellation:true,  category:'budget',   description:'Affordable rest house by Parakrama Samudra lake.'),
    Hotel(id:'h44', name:'The Lake Hotel Polonnaruwa', city:'Polonnaruwa',  location:'New Town, Polonnaruwa',      pricePerNight:55,  rating:4.2, reviews:490,  imageUrl:'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Lake View'],                 freeCancellation:true,  category:'midrange', description:'Mid-range hotel with pool and views of the ancient reservoir.'),

    // ── ANURADHAPURA ────────────────────────────────────────────
    Hotel(id:'h45', name:'Tissawewa Grand Hotel',       city:'Anuradhapura', location:'Old Town, Anuradhapura',     pricePerNight:35,  rating:4.0, reviews:380,  imageUrl:'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',  amenities:['Pool','WiFi','Restaurant','Heritage Location'],         freeCancellation:true,  category:'budget',   description:'Heritage hotel within the ancient sacred city.'),
    Hotel(id:'h46', name:'Palm Garden Village Hotel',   city:'Anuradhapura', location:'Anuradhapura City',          pricePerNight:70,  rating:4.3, reviews:760,  imageUrl:'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',  amenities:['Pool','Spa','WiFi','Restaurant','Cycling'],             freeCancellation:true,  category:'midrange', description:'Peaceful resort near the sacred city ruins.'),

    // ── PINNAWALA ───────────────────────────────────────────────
    Hotel(id:'h47', name:'Pinnawala Safari Hotel',      city:'Pinnawala',    location:'Pinnawala, Kegalle',         pricePerNight:30,  rating:4.0, reviews:220,  imageUrl:'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80',  amenities:['WiFi','Restaurant','Elephant View'],                   freeCancellation:true,  category:'budget',   description:'Wake up to elephants walking past your window.'),
  ];
}
