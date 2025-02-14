

class CatalogModel {
  static List<Item> items = []; // start with empty list
}

class Item {
  final num id;
  final String name;
  final String location;
  final num area;
  final String crop;
  final String secratory;

  // Constructor with required fields
  Item({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.crop,
    required this.secratory,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map["id"] ?? 0,
      name: map["name"] ?? '',
      location: map["location"] ?? '',
      area: map["area"] != null ? num.parse(map["area"].toString()) : 0,
      crop: map["crop"] ?? '',
      secratory: map["secratory"] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "location": location,
        "area": area,
        "crop": crop,
        "secratory": secratory,
      };
}
