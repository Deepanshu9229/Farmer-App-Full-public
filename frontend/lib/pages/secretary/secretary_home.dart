import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/cookie_manager.dart'; // This file holds your global sessionCookie
import 'package:frontend/widgets/drawer.dart';

class SecretaryHome extends StatefulWidget {
  final String area; // The area the secretary controls
  const SecretaryHome({Key? key, required this.area}) : super(key: key);

  @override
  _SecretaryHomeState createState() => _SecretaryHomeState();
}

class _SecretaryHomeState extends State<SecretaryHome> {
  late Future<List<dynamic>> farmsFuture;

  // Fetch farms from the backend API.
  Future<List<dynamic>> fetchFarms() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // This URL must match your backend route for secretary home farms.
    final String url = "$baseUrl/api/secretary/home/farms";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "",
        },
      );
      if (response.statusCode == 200) {
        // Expecting an array of farm details.
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch farms: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    farmsFuture = fetchFarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Secretary Home - ${widget.area}"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: farmsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No farms found for this area"));
          } else {
            final farms = snapshot.data!;
            return ListView.builder(
              itemCount: farms.length,
              itemBuilder: (context, index) {
                final farm = farms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.agriculture),
                    title: Text(
                      farm['farmName'] ?? 'Unknown Farm',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Farmer: ${farm['farmerName'] ?? 'Unknown'}\nLocation: ${farm['location'] ?? 'Unknown'}",
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
       drawer: const MyDrawer(),
    );
  }
}
