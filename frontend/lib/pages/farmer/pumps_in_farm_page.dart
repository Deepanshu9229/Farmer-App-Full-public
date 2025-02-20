import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:frontend/models/farm.dart';
import 'package:frontend/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';

class PumpInFarmPage extends StatefulWidget {
  const PumpInFarmPage({super.key});

  @override
  State<PumpInFarmPage> createState() => _PumpInFarmPageState();
}

class _PumpInFarmPageState extends State<PumpInFarmPage> {
  List<Item> farms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFarms(); // Dynamically fetch farms from backend on startup
  }

  // Fetch farms from backend API
  Future<void> fetchFarms() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/farms";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> farmData = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          farms = farmData.map((data) => Item.fromMap(data)).toList();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Unable to fetch farms")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pump in Farm",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : farms.isNotEmpty
              ? ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final item = farms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            item.name.isNotEmpty ? item.name[0] : '',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          "Pumps in : ${item.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Location: ${item.location}\nPincode: ${item.pincode}\nAddress: ${item.address}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () {
                          Navigator.pushNamed(context, MyRoutes.pumpsRoute, arguments: {
                            'farmId': item.id,
                            'farmName': item.name,
                          });
                        },
                      ),
                    );
                  },
                )
              : const Center(child: Text("No farms found.")),
    );
  }
}
