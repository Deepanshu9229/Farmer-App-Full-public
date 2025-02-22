import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/widgets/drawer.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<List<dynamic>> secretariesFuture;

  // Fetch secretaries and their associated farms from the backend API.
  Future<List<dynamic>> fetchSecretaries() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // Use the correct URL (without a placeholder).
    final String url = "$baseUrl/api/admin/home/secretaries";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch secretaries: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    secretariesFuture = fetchSecretaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home - Secretaries"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: secretariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No secretaries found."));
          } else {
            final secretaries = snapshot.data!;
            return ListView.builder(
              itemCount: secretaries.length,
              itemBuilder: (context, index) {
                final secData = secretaries[index];
                final secretary = secData['secretary'];
                final farms = secData['farms'];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      secretary['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Mobile: ${secretary['mobileNumber'] ?? 'N/A'}"),
                    children: [
                      if (farms != null && farms is List && farms.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: farms.length,
                          itemBuilder: (context, i) {
                            final farm = farms[i];
                            return ListTile(
                              title: Text(farm['farmName'] ?? 'Unknown Farm'),
                              subtitle: Text(
                                  "Location: ${farm['location'] ?? 'Unknown'}\nFarmer: ${farm['farmerName'] ?? 'Unknown'}"),
                            );
                          },
                        )
                      else
                        const ListTile(
                          title: Text("No farms available."),
                        )
                    ],
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
