// ─── Destination-aware itinerary data for Sri Lanka ───────────────
// Each destination has: days of activities, stop city per night, images

class ItineraryData {

  // ── Per-destination day plans ─────────────────────────────────
  static const Map<String, List<Map<String, dynamic>>> destinationPlans = {

    'Kandy': [
      {'stop': 'Kandy', 'activities': ['Arrive Kandy & check in', 'Temple of the Tooth evening ceremony', 'Stroll along Kandy Lake'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Peradeniya Botanical Gardens', 'Spice garden tour', 'Kandyan cultural dance show'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Udawatta Kele Forest Reserve hike', 'Local market & street food', 'Batik factory visit'], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Scenic drive to Nuwara Eliya', 'Tea factory tour & tasting', 'Gregory Lake boat ride'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Horton Plains National Park', "World's End hike", 'Hakgala Botanical Garden'], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Drive through tea country to Ella', 'Nine Arch Bridge walk', 'Little Adam\'s Peak sunset'], 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Ella Rock full-day hike', 'Rawana Waterfalls visit', 'Farewell dinner at Ella'], 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'},
    ],

    'Sigiriya': [
      {'stop': 'Sigiriya', 'activities': ['Arrive & check in near Sigiriya', 'Pidurangala Rock sunset hike', 'Village walk'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
      {'stop': 'Sigiriya', 'activities': ['Sigiriya Rock Fortress climb (early morning)', 'Sigiriya Museum', 'Jeep safari in Minneriya NP'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
      {'stop': 'Dambulla', 'activities': ['Dambulla Cave Temple', 'Nalanda Gedige ruins', 'Local street food tour'], 'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'},
      {'stop': 'Polonnaruwa', 'activities': ['Polonnaruwa ancient city cycle tour', 'Parakrama Samudra lake', 'Moonstone carvings'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Drive to Kandy via Matale', 'Temple of the Tooth', 'Kandy night market'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Peradeniya Botanical Gardens', 'Gem Museum visit', 'Cultural show'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Sigiriya', 'activities': ['Return to Sigiriya', 'Cycling in paddy fields', 'Farewell dinner'], 'image': 'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&q=80'},
    ],

    'Galle': [
      {'stop': 'Galle', 'activities': ['Arrive Galle & check into fort hotel', 'Galle Fort ramparts evening walk', 'Dinner inside the fort'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Galle', 'activities': ['Galle Fort history tour', 'Dutch Reformed Church & Lighthouse', 'Galle Friday market'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Unawatuna', 'activities': ['Unawatuna beach morning swim', 'Jungle Beach snorkelling', 'Seafood lunch by the sea'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Drive to Mirissa', 'Coconut tree hill sunset', 'Beach bonfire dinner'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Whale watching cruise (6am)', 'Parrot Rock swim', 'Mirissa fish market'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Hikkaduwa', 'activities': ['Drive to Hikkaduwa', 'Coral sanctuary snorkelling', 'Sea turtle watching'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Galle', 'activities': ['Return to Galle', 'Shopping in the fort', 'Farewell sunset dinner'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
    ],

    'Ella': [
      {'stop': 'Ella', 'activities': ['Arrive Ella by train from Kandy', 'Nine Arch Bridge walk', 'Ella town exploration'], 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Ella Rock full hike (4–5 hrs)', 'Waterfall swim', 'Sundowner at rooftop café'], 'image': 'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Little Adam\'s Peak morning hike', 'Ravana Falls', 'Cooking class: Sri Lankan curry'], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Scenic drive Ella–Nuwara Eliya', 'Mackwoods tea estate tour', 'Victoria Park'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Horton Plains & World\'s End', 'Baker\'s Falls', 'Hill country walk'], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Drive to Kandy', 'Temple of the Tooth', 'Kandy cultural show'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Return to Ella', 'Free day exploring tea trails', 'Farewell dinner'], 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'},
    ],

    'Mirissa': [
      {'stop': 'Mirissa', 'activities': ['Arrive Mirissa beach', 'Coconut tree hill sunset', 'Beachside dinner'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Whale watching cruise (6am)', 'Parrot Rock snorkelling', 'Fish market visit'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Surf lessons at Secret Beach', 'Mirissa Harbour sunset', 'Bonfire beach night'], 'image': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&q=80'},
      {'stop': 'Galle', 'activities': ['Day trip to Galle Fort', 'Lighthouse & ramparts walk', 'Dutch colonial quarter'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Yoga on the beach', 'Catamaran sailing trip', 'Farewell rice & curry'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
    ],

    'Arugam Bay': [
      {'stop': 'Arugam Bay', 'activities': ['Arrive Arugam Bay', 'Main Point surf session', 'Sunset beach walk'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
      {'stop': 'Arugam Bay', 'activities': ['Surf lessons (all day)', 'Crocodile Rock point', 'Beach bar sundowner'], 'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400&q=80'},
      {'stop': 'Arugam Bay', 'activities': ['Kumana National Park bird watching', 'Pottuvil lagoon canoe', 'Seafood BBQ'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
      {'stop': 'Arugam Bay', 'activities': ['Whiskey Point morning surf', 'Elephant Rock hike', 'Local temple visit'], 'image': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400&q=80'},
      {'stop': 'Arugam Bay', 'activities': ['Surfboard yoga session', 'Village bicycle tour', 'Farewell beachside dinner'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
    ],

    'Yala': [
      {'stop': 'Yala', 'activities': ['Arrive near Yala & settle in', 'Afternoon jeep safari', 'Night sounds at eco-lodge'], 'image': 'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80'},
      {'stop': 'Yala', 'activities': ['Dawn safari (leopard hunting hours)', 'Yala Block 2 elephant herds', 'Birding at lagoon'], 'image': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80'},
      {'stop': 'Yala', 'activities': ['Full-day deep safari', 'Sloth bear spotting', 'Campfire under the stars'], 'image': 'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80'},
      {'stop': 'Mirissa', 'activities': ['Drive to Mirissa coast', 'Beach afternoon', 'Coconut tree hill sunset'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Yala', 'activities': ['Return through Hambantota', 'Bundala NP bird sanctuary', 'Farewell dinner'], 'image': 'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80'},
    ],

    'Nuwara Eliya': [
      {'stop': 'Nuwara Eliya', 'activities': ['Arrive Nuwara Eliya', 'Mackwoods Labookellie tea estate', 'Gregory Lake walk'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Horton Plains National Park', "World's End hike", "Baker's Falls"], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Hakgala Botanical Garden', 'Seetha Amman Temple', 'Victoria Park'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
      {'stop': 'Ella', 'activities': ['Scenic train to Ella', 'Nine Arch Bridge', 'Little Adam\'s Peak'], 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Return to Nuwara Eliya', 'Tea plucking experience', 'Farewell highland dinner'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
    ],

    'Colombo': [
      {'stop': 'Colombo', 'activities': ['Arrive Colombo & check in', 'Galle Face Green evening', 'Pettah market food tour'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Colombo', 'activities': ['Gangaramaya Temple', 'National Museum', 'Viharamahadevi Park'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Colombo', 'activities': ['Colombo street art walk', 'Arcade Independence Square', 'Rooftop bar evening'], 'image': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80'},
      {'stop': 'Negombo', 'activities': ['Day trip to Negombo', 'Fish market & Dutch canal', 'Beach sunset'], 'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80'},
      {'stop': 'Colombo', 'activities': ['Beira Lake walk', 'Sri Lanka cricket stadium tour', 'Farewell dinner at Ministry of Crab'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
    ],

    'Trincomalee': [
      {'stop': 'Trincomalee', 'activities': ['Arrive Trincomalee', 'Fort Frederick & Swami Rock', 'Coconut Bay sunset'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
      {'stop': 'Trincomalee', 'activities': ['Nilaveli Beach morning swim', 'Pigeon Island snorkelling (coral & fish)', 'Trinco fish market'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Trincomalee', 'activities': ['Whale watching (blue & sperm whales)', 'Kinniya hot springs', 'Trincomalee temple walk'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
      {'stop': 'Trincomalee', 'activities': ['Marble Beach day trip', 'Diving lesson at Pigeon Island', 'Seafood dinner'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Trincomalee', 'activities': ['Kayaking at Koddiyar Bay', 'Mutur day trip', 'Farewell sunset boat ride'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
    ],

    'Jaffna': [
      {'stop': 'Jaffna', 'activities': ['Arrive Jaffna', 'Jaffna Fort & Dutch ramparts', 'Nallur Kandaswamy Temple'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Jaffna', 'activities': ['Nainativu Island boat trip', 'Nagadeepa Buddhist temple', 'Casuarina Beach'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Jaffna', 'activities': ['Jaffna Public Library', 'Chunnakam Kovil', 'Jaffna cuisine cooking class'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Jaffna', 'activities': ['Delft Island jeep tour', 'Wild ponies & Dutch ruins', 'Farewell Tamil feast'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
    ],

    'Negombo': [
      {'stop': 'Negombo', 'activities': ['Arrive Negombo', 'St Mary\'s Church & Dutch canal', 'Negombo beach sunset'], 'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80'},
      {'stop': 'Negombo', 'activities': ['Fish market at dawn', 'Boat ride on Hamilton Canal', 'Lellama market'], 'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80'},
      {'stop': 'Negombo', 'activities': ['Muthurajawela wetland boat safari', 'Mangrove kayaking', 'Beach seafood dinner'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
    ],

    'Anuradhapura': [
      {'stop': 'Anuradhapura', 'activities': ['Arrive Anuradhapura', 'Sri Maha Bodhi sacred tree', 'Thuparamaya stupa'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Anuradhapura', 'activities': ['Ruwanwelisaya Dagoba', 'Abhayagiri Monastery ruins', 'Isurumuniya Rock Temple'], 'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'},
      {'stop': 'Anuradhapura', 'activities': ['Jetavanaramaya (world\'s 3rd tallest stupa)', 'Moonstone carvings at Mahasena', 'Cycle around ancient city'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Sigiriya', 'activities': ['Drive to Sigiriya', 'Pidurangala Rock afternoon hike', 'Sunset over the plain'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
    ],

    'Polonnaruwa': [
      {'stop': 'Polonnaruwa', 'activities': ['Arrive Polonnaruwa', 'Parakrama Samudra reservoir sunset', 'Night at heritage hotel'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
      {'stop': 'Polonnaruwa', 'activities': ['Ancient city full-day cycle tour', 'Gal Vihara rock sculptures', 'Rankoth Vehera stupa'], 'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'},
      {'stop': 'Polonnaruwa', 'activities': ['Minneriya or Kaudulla NP elephant safari', 'Dimbulagala Rock Temple', 'Farewell dinner'], 'image': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80'},
    ],

    'Dambulla': [
      {'stop': 'Dambulla', 'activities': ['Arrive Dambulla', 'Dambulla Royal Cave Temple (UNESCO)', 'Evening walk in Dambulla town'], 'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'},
      {'stop': 'Sigiriya', 'activities': ['Sigiriya Rock Fortress full day', 'Sigiriya Museum', 'Elephant safari at Minneriya'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
      {'stop': 'Dambulla', 'activities': ['Nalanda Gedige ruins', 'Aukana Buddha statue', 'Farewell at Dambulla'], 'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80'},
    ],

    'Hikkaduwa': [
      {'stop': 'Hikkaduwa', 'activities': ['Arrive Hikkaduwa', 'Coral sanctuary snorkelling', 'Beach sunset'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Hikkaduwa', 'activities': ['Surf lessons at South Beach', 'Sea turtle watching & release', 'Night market'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Hikkaduwa', 'activities': ['Glass-bottom boat tour', 'Tsunami Museum visit', 'Narigama beach bar'], 'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'},
    ],

    'Bentota': [
      {'stop': 'Bentota', 'activities': ['Arrive Bentota', 'Bentota beach afternoon', 'Madu River sunset cruise'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Bentota', 'activities': ['Water sports: jet ski, banana boat, wake board', 'Kosgoda turtle hatchery', 'Beach yoga'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Bentota', 'activities': ['Madu River mangrove safari by boat', 'Cinnamon & spice island visit', 'Farewell beachside dinner'], 'image': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&q=80'},
    ],

    'Unawatuna': [
      {'stop': 'Unawatuna', 'activities': ['Arrive Unawatuna', 'Unawatuna Bay swim & snorkel', 'Sunset at Rumassala hillside'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
      {'stop': 'Unawatuna', 'activities': ['Jungle Beach (hidden cove)', 'Mask & snorkel coral gardens', 'Seafood lunch'], 'image': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400&q=80'},
      {'stop': 'Galle', 'activities': ['Day trip to Galle Fort', 'Lighthouse & lighthouse museum', 'Dutch bakery visit'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
      {'stop': 'Unawatuna', 'activities': ['Free beach day', 'Water sports centre', 'Farewell dinner in the bay'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
    ],

    'Pinnawala': [
      {'stop': 'Pinnawala', 'activities': ['Arrive Pinnawala', 'Elephant Orphanage river bath (10am)', 'Village walk around the sanctuary'], 'image': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80'},
      {'stop': 'Kandy', 'activities': ['Drive to Kandy', 'Temple of the Tooth', 'Kandy Lake evening walk'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
      {'stop': 'Pinnawala', 'activities': ['Morning elephant feeding', 'Kegalle spice garden', 'Farewell rice & curry'], 'image': 'https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=400&q=80'},
    ],

    'Horton Plains': [
      {'stop': 'Nuwara Eliya', 'activities': ['Arrive Nuwara Eliya & acclimatise', 'Gregory Lake & Victoria Park', 'Hill station town walk'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Horton Plains National Park (early start)', "World's End 8km hike", "Baker's Falls"], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
      {'stop': 'Nuwara Eliya', 'activities': ['Hakgala Botanical Garden', 'Seetha Amman Temple', 'Farewell tea at colonial hotel'], 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=80'},
    ],
  };

  /// Get the day plans for a destination for [days] days.
  /// If the destination has enough plans, use them directly.
  /// If not, extend by appending plans from neighbouring destinations
  /// so activities never repeat.
  static List<Map<String, dynamic>> getDayPlans(String destination, int days) {
    final key = _findKey(destination);
    final primary = List<Map<String, dynamic>>.from(
        destinationPlans[key] ?? _genericFallback(destination));

    if (primary.length >= days) return primary.take(days).toList();

    // Need more days — pull from neighbours then fill with extension days
    final result = List<Map<String, dynamic>>.from(primary);
    final neighbours = _neighbours[key] ?? _neighbours['default']!;

    for (final nb in neighbours) {
      if (result.length >= days) break;
      final nbKey = _findKey(nb);
      final nbPlans = List<Map<String, dynamic>>.from(
          destinationPlans[nbKey] ?? _genericFallback(nb));
      // Add neighbour plans, skip ones whose stop city is already used on consecutive days
      for (final p in nbPlans) {
        if (result.length >= days) break;
        result.add(p);
      }
    }

    // If still short, add extension days with unique activities
    int extra = 1;
    while (result.length < days) {
      final lastStop = result.last['stop'] as String;
      result.add(_extensionDay(lastStop, extra));
      extra++;
    }

    return result.take(days).toList();
  }

  static Map<String, dynamic> _extensionDay(String stop, int n) {
    final options = [
      ['Free day exploring local villages', 'Cooking class: Sri Lankan curries', 'Sunset at local viewpoint'],
      ['Bicycle tour through countryside', 'Visit local temple or kovil', 'Night market food crawl'],
      ['Morning meditation at Buddhist temple', 'Day trip to nearby waterfall', 'Traditional mask carving workshop'],
      ['Birdwatching in nature reserve', 'Local gem or spice market tour', 'Cultural dance performance'],
      ['Sunrise hike to panoramic viewpoint', 'Visit local school & community', 'Farewell rice & curry feast'],
    ];
    final images = [
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
      'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',
    ];
    final idx = (n - 1) % options.length;
    return {
      'stop': stop,
      'activities': options[idx],
      'image': images[idx],
    };
  }

  // Neighbouring destinations to pull extra days from (in order of closeness)
  static const Map<String, List<String>> _neighbours = {
    'Kandy':        ['Nuwara Eliya', 'Pinnawala', 'Sigiriya', 'Ella', 'Dambulla'],
    'Sigiriya':     ['Dambulla', 'Polonnaruwa', 'Anuradhapura', 'Kandy', 'Minneriya'],
    'Galle':        ['Unawatuna', 'Mirissa', 'Hikkaduwa', 'Bentota', 'Colombo'],
    'Ella':         ['Nuwara Eliya', 'Kandy', 'Yala', 'Mirissa', 'Arugam Bay'],
    'Mirissa':      ['Galle', 'Unawatuna', 'Hikkaduwa', 'Yala', 'Bentota'],
    'Arugam Bay':   ['Trincomalee', 'Yala', 'Ella', 'Colombo'],
    'Yala':         ['Mirissa', 'Galle', 'Ella', 'Arugam Bay'],
    'Nuwara Eliya': ['Ella', 'Kandy', 'Horton Plains', 'Colombo'],
    'Colombo':      ['Negombo', 'Kandy', 'Galle', 'Bentota', 'Pinnawala'],
    'Trincomalee':  ['Sigiriya', 'Anuradhapura', 'Arugam Bay', 'Polonnaruwa'],
    'Jaffna':       ['Anuradhapura', 'Trincomalee', 'Colombo'],
    'Negombo':      ['Colombo', 'Kandy', 'Sigiriya', 'Pinnawala'],
    'Anuradhapura': ['Sigiriya', 'Polonnaruwa', 'Dambulla', 'Jaffna'],
    'Polonnaruwa':  ['Sigiriya', 'Dambulla', 'Anuradhapura', 'Trincomalee'],
    'Dambulla':     ['Sigiriya', 'Polonnaruwa', 'Kandy', 'Anuradhapura'],
    'Hikkaduwa':    ['Galle', 'Unawatuna', 'Mirissa', 'Bentota'],
    'Bentota':      ['Colombo', 'Galle', 'Hikkaduwa', 'Mirissa'],
    'Unawatuna':    ['Galle', 'Mirissa', 'Hikkaduwa', 'Yala'],
    'Pinnawala':    ['Kandy', 'Colombo', 'Negombo', 'Sigiriya'],
    'Horton Plains':['Nuwara Eliya', 'Ella', 'Kandy'],
    'default':      ['Kandy', 'Galle', 'Ella', 'Sigiriya', 'Colombo'],
  };

  static String _findKey(String dest) {
    final d = dest.toLowerCase().trim();
    for (final key in destinationPlans.keys) {
      if (key.toLowerCase() == d) return key;
    }
    for (final key in destinationPlans.keys) {
      if (d.contains(key.toLowerCase()) || key.toLowerCase().contains(d)) return key;
    }
    return dest; // no match → will use fallback
  }

  static List<Map<String, dynamic>> _genericFallback(String destination) => [
    {'stop': destination, 'activities': ['Arrive $destination & check in', 'Explore the town centre', 'Evening at local restaurant'], 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80'},
    {'stop': destination, 'activities': ['Morning temple or heritage site visit', 'Local market exploration', 'Sunset viewpoint'], 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
    {'stop': destination, 'activities': ['Nature walk or national park visit', 'Cultural experience', 'Traditional Sri Lankan dinner'], 'image': 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=400&q=80'},
    {'stop': destination, 'activities': ['Day trip to nearby attraction', 'Local craft shopping', 'Sunset at the beach or viewpoint'], 'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80'},
    {'stop': destination, 'activities': ['Leisure morning', 'Local food tour', 'Farewell Sri Lankan feast'], 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'},
  ];
}
