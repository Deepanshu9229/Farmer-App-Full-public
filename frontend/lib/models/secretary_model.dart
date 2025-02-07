class Secretary {
  final int id;
  final String name;
  final String area;
  final List<Farmer> farmers;

  Secretary({
    required this.id,
    required this.name,
    required this.area,
    required this.farmers,
  });

  factory Secretary.fromJson(Map<String, dynamic> json) {
    var farmerList = json['farmers'] as List;
    List<Farmer> farmers = farmerList.map((i) => Farmer.fromJson(i)).toList();

    return Secretary(
      id: json['id'],
      name: json['name'],
      area: json['area'],
      farmers: farmers,
    );
  }
}

class Farmer {
  final int id;
  final String name;
  final String farmName;
  final String crop;
  final String size;

  Farmer({
    required this.id,
    required this.name,
    required this.farmName,
    required this.crop,
    required this.size,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      name: json['name'],
      farmName: json['farmName'],
      crop: json['crop'],
      size: json['size'],
    );
  }
}
