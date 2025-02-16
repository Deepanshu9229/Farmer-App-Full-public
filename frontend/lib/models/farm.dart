class CatalogModel {
  static List<Item> items = []; // start with empty list
}

class Item {
  final num id;
  final String name;
  final String location;
  final String pincode;
  final String address;

  // Constructor with required fields
  Item({
    required this.id,
    required this.name,
    required this.location,
    required this.pincode,
    required this.address,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map["id"] ?? 0,
      name: map["name"] ?? '',
      location: map["location"] ?? '',
      pincode: map["pincode"]?.toString() ?? '',
      address: map["address"] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "location": location,
        "pincode": pincode,
        "address": address,
      };
}
