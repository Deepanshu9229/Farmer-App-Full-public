import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:frontend/models/farm.dart'; // For CatalogModel and Item classes
import 'package:frontend/utils/routes.dart';
import 'pumps_page.dart';

class PumpInFarm extends StatefulWidget {
  const PumpInFarm({super.key});

  @override
  State<PumpInFarm> createState() => _PumpInFarmState();
}

class _PumpInFarmState extends State<PumpInFarm> {
  // Widget initialization with pre-loaded data
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final farmJson = await rootBundle.loadString("assets/files/farm.json");
    final decodedData = jsonDecode(farmJson); // Convert JSON to string (map)
    var farmsData = decodedData["farmData"];

    // Update the list with data from JSON
    CatalogModel.items =
        List.from(farmsData).map<Item>((item) => Item.fromMap(item)).toList();
    setState(() {}); // Refresh the UI after loading data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Farm Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade200,
        ),
        body: CatalogModel.items.isNotEmpty
            ? ListView.builder(
                itemCount: CatalogModel.items.length,
                itemBuilder: (context, index) {
                  return ItemWidget(
                    item: CatalogModel.items[index],
                  );
                },
              )
            : const Center(
                child:
                    CircularProgressIndicator(), // Loading indicator while data is being fetched
              ));
  }
}

// Card Widget for displaying individual item
class ItemWidget extends StatelessWidget {
  final Item item;

  const ItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            item.name[0], // Display the first letter of the name
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Pumps in ${item.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${item.location}\n"
          "Area: ${item.area} acres\n"
          "Crop: ${item.crop}\n"
          "Secretary: ${item.secratory}",
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PumpsPage(farmName: item.name),
            ),
          );
        },
      ),
    );
  }
}
