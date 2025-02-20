import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:frontend/models/farm.dart';
import 'package:frontend/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:frontend/widgets/farm_item_widget.dart'; // Import the widget

class FarmPage extends StatefulWidget {
  const FarmPage({super.key});

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  List<Item> farms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFarms(); // Fetch farms from backend on startup
  }

  // Fetch farms from backend API
  Future<void> fetchFarms() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/farms";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? "",
      });
      if (response.statusCode == 200) {
        List<dynamic> farmData = jsonDecode(response.body);
        setState(() {
          farms = farmData.map((data) => Item.fromMap(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Unable to fetch farms")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Function to add a new farm via backend API
  Future<void> addFarm(
      String name, String location, String pincode, String address) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/farms/add"; // endpoint for adding a farm

    final headers = {
      "Content-Type": "application/json",
      "Cookie": sessionCookie ?? ""
    };
    print("Using session cookie: $sessionCookie");
    print("AddFarm URL: $url");
    print("Headers: $headers");

    final body = jsonEncode({
      "name": name,
      "pincode": pincode,
      "location": location,
      "address": address,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ??
                  'Farm added successfully!')),
        );
        fetchFarms(); // Refresh list after adding new farm
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
      }
    } catch (error) {
      print("AddFarm error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    }
  }

  // Function to delete a farm via backend API
  Future<void> deleteFarm(String farmId) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/farms/$farmId";
    final headers = {
      "Content-Type": "application/json",
      "Cookie": sessionCookie ?? "",
    };

    print("Deleting farm with id: $farmId");
    print("DeleteFarm URL: $url");
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Farm deleted successfully")),
        );
        fetchFarms();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
      }
    } catch (error) {
      print("DeleteFarm error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server: $error")),
      );
    }
  }

  // Show dialog to add new farm
  void _showAddFarmDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController pincodeController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Farm"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Farm Name"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: pincodeController,
                decoration: const InputDecoration(labelText: "Pincode"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              addFarm(
                nameController.text,
                locationController.text,
                pincodeController.text,
                addressController.text,
              );
              Navigator.pop(context); // Close dialog after submission
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farm Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : farms.isNotEmpty
              ? ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final item = farms[index];
                    return FarmItemWidget(
                      item: item,
                      onDelete: () {
                        deleteFarm(item.id.toString());
                      },
                    );
                  },
                )
              : const Center(child: Text("No farms found.")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFarmDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
