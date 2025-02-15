import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:frontend/models/farm.dart'; // For CatalogModel and Item classes
import 'package:frontend/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';



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
      final response = await http.get(Uri.parse(url));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Function to add a new farm via backend API
  Future<void> addFarm(String name, String location, String pincode, String address) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
        final String url = "$baseUrl/api/farmer/add"; // Correct endpoint for adding a farm
          
          // Include the cookie from our global variable
          final headers = {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? ""
              };

    final body = jsonEncode({
      "name": name,
      "mobileNumber": "", // Omit if not needed, or pass proper mobile number if required
      "city": location,   // Adjust key if needed
      "pincode": pincode,
      "residentialAddress": address,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 201) {
        // On success, show message and refresh the farm list
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Farm added successfully!')),
        );
        fetchFarms(); // Refresh list after adding new farm
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['message']}")),
        );
      }
    } catch (error) {
      print("Signup Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    }
  } // <-- Added missing closing brace for addFarm

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
              // Call addFarm function with the entered details
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
        title: const Text("Farm Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : farms.isNotEmpty
              ? ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    return FarmItemWidget(item: farms[index]);
                  },
                )
              : const Center(child: Text("No farms found.")),
      // Floating "Add" button to open the add farm dialog
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFarmDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Card Widget for displaying individual farm details
class FarmItemWidget extends StatelessWidget {
  final Item item;

  const FarmItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            item.name[0], // Display the first letter of the name
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.name,
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
          // Pass the farm ID and name to the pump page.
          Navigator.pushNamed(context, MyRoutes.pumpsfarmRoute, arguments: {
            'farmId': item.id,
            'farmName': item.name,
          });
        },
      ),
    );
  }
}
