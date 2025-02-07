import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/secretary_model.dart';

class SecretaryHome extends StatefulWidget {
  final String area;

  const SecretaryHome({super.key, required this.area});

  @override
  _SecretaryHomeState createState() => _SecretaryHomeState();
}

class _SecretaryHomeState extends State<SecretaryHome> {
  late Future<List<Farmer>> farmers;

  Future<List<Farmer>> loadFarmers() async {
    // Load JSON file from assets/files
    String jsonString = await rootBundle.loadString('assets/files/secretary.json');
    final data = json.decode(jsonString);

    // Find the secretary by area
    final secretary = data['secretaries'].firstWhere(
      (sec) => sec['area'] == widget.area,
      orElse: () => null,
    );

    if (secretary != null) {
      // Parse farmer data
      Secretary secData = Secretary.fromJson(secretary);
      return secData.farmers;
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    farmers = loadFarmers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Secretary Home - ${widget.area}")),
      body: FutureBuilder<List<Farmer>>(
        future: farmers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Farmers Found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final farmer = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(farmer.name),
                    subtitle: Text("${farmer.farmName} - ${farmer.crop}"),
                    trailing: Text(farmer.size),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
