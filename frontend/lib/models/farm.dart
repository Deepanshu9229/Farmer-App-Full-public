class CatalogModel {
  static List<Item> items = []; // start with empty list
}

class Item {
  final String id; // use String for MongoDB _id
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
      // Check for '_id' first then 'id'
      id: map["_id"]?.toString() ?? map["id"]?.toString() ?? '',
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
