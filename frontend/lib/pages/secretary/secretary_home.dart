import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:http/http.dart' as http;

class SecretaryHome extends StatefulWidget {
  final String area;
  const SecretaryHome({Key? key, required this.area}) : super(key: key);

  @override
  _SecretaryHomeState createState() => _SecretaryHomeState();
}

class _SecretaryHomeState extends State<SecretaryHome> {
  late Future<List<dynamic>> farmsFuture;

  Future<List<dynamic>> fetchFarms() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // Backend route for secretary's farms (ensure this matches the backend)
    final String url = "$baseUrl/api/secretary/home/farms";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? "",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch farms: ${response.body}");
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
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          else if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          else if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("No farms found for this area"));
          else {
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
    );
  }
}
