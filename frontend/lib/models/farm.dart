

class CatalogModel{
  static List<Item> items = []; //start with empty list
}

class Item {
  final num id;
  final String name;
  final String location;
  final num area;
  final String crop;
  final String secratory;

// constructor bana diya bulb me click kr k 
  Item({required this.id, required this.name, required this.location, required this.area, required this.crop, required this.secratory});

factory Item.fromMap(Map<String, dynamic> map){
  return Item(
    id : map["id"],
    name : map["name"],
    location : map["location"],
    area: num.parse(map["area"]), // Ensure numeric parsing
    crop : map["crop"],
    secratory : map["secratory"],
  );
}

toMap() => {
  "id" : id,
  "name" : name,
  "location" : location,
  "area" : area,
  "crop" : crop,
  "secratory" : secratory,
};

}
