import 'package:flutter/foundation.dart';

class PumpModel {
  static List<Item> items = []; // Start with an empty list
}

class Item {
  final num id;
  final String location;
  final bool status;
  final num timer;

  Item({
    required this.id,
    required this.location,
    required this.status,
     required this.timer,
  });

  // Factory constructor to parse from Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map["id"],
      location: map["location"],
      status: map["status"].toString().toLowerCase() == "true", // Convert string to bool
      timer: map["timer"].toString().isEmpty ? 0 : num.parse(map["timer"]),
    );
  }

  // Convert Item to Map
  Map<String, dynamic> toMap() => {
        "id": id,
        "location": location,
        "status": status,
        "timer": timer,
      };
}
