import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:http/http.dart' as http;

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<List<dynamic>> secretariesFuture;

  // Fetch secretaries from the backend API.
  Future<List<dynamic>> fetchSecretaries() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // Adjust this URL to match your backend endpoint for admin home secretaries.
    final String url = "$baseUrl/api/admin/home/secretaries/:secretaryId/farms";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "",
        },
      );
      if (response.statusCode == 200) {
        // The backend should return a JSON array of secretary details.
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
                final secretary = secretaries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      secretary['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mobile: ${secretary['mobileNumber'] ?? 'N/A'}"),
                        Text("Pincode: ${secretary['pincode'] ?? 'N/A'}"),
                        Text("Address: ${secretary['residentialAddress'] ?? 'N/A'}"),
                        if (secretary['areaInControl'] != null)
                          Text(
                            "Area: ${secretary['areaInControl']['areaName'] ?? 'N/A'} (${secretary['areaInControl']['pinCode'] ?? 'N/A'})",
                          ),
                      ],
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
