import 'package:flutter/foundation.dart';

class PumpModel {
  static List<Pump> items = []; // Start with an empty list
}

class Pump {
  final String id;
  final String location;
  final bool status;
  final num timer;

  Pump({
    required this.id,
    required this.location,
    required this.status,
    required this.timer,
  });

  factory Pump.fromMap(Map<String, dynamic> map) {
    return Pump(
      id: map["_id"]?.toString() ?? map["id"]?.toString() ?? '',
      location: map["location"]?.toString() ?? '',
      status: map["status"] is bool
          ? map["status"]
          : (map["status"]?.toString().toLowerCase() == "true"),
      timer: (map["timer"] == null || map["timer"].toString().isEmpty)
          ? 0
          : num.parse(map["timer"].toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "location": location,
        "status": status,
        "timer": timer,
      };

  Pump copyWith({
    String? id,
    String? location,
    bool? status,
    num? timer,
  }) {
    return Pump(
      id: id ?? this.id,
      location: location ?? this.location,
      status: status ?? this.status,
      timer: timer ?? this.timer,
    );
  }
}
