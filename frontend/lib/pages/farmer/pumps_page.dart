import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:frontend/models/pump_model.dart';
import 'package:frontend/widgets/pump_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class PumpsPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const PumpsPage({super.key, required this.farmId, required this.farmName});

  @override
  State<PumpsPage> createState() => _PumpsPageState();
}

class _PumpsPageState extends State<PumpsPage> {
  List<Pump> pumps = [];
  bool isLoading = true;
  List<WiFiAccessPoint> availableNetworks = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    fetchPumps();
  }

  // Request permissions for Wi-Fi scanning.
  Future<void> requestPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    debugPrint(status.isGranted
        ? "Location permission granted."
        : "Location permission is required to scan Wi-Fi networks.");
  }

  // Fetch pumps from backend API.
  Future<void> fetchPumps() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/${widget.farmId}/pumps";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? "",
      });
      if (response.statusCode == 200) {
        List<dynamic> pumpData = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          pumps = pumpData.map((data) => Pump.fromMap(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Unable to fetch pumps")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Delete a pump via backend API.
  Future<void> deletePump(String pumpId) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/${widget.farmId}/pumps/$pumpId";
    final headers = {
      "Content-Type": "application/json",
      "Cookie": sessionCookie ?? "",
    };

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pump deleted successfully")),
        );
        fetchPumps();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to connect to server: $error")));
    }
  }

  // Dialog to add a new pump.
  void _showAddPumpDialog() {
    final pumpNameController = TextEditingController();
    final idController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Pump"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pumpNameController,
                decoration: const InputDecoration(labelText: "Pump Name"),
              ),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pump ID"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    const Text("Scan Wi-Fi to Connect"),
                    IconButton(
                      icon: const Icon(Icons.wifi),
                      onPressed: _showWiFiDialog,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final pumpName = pumpNameController.text.trim();
              final id = idController.text.trim();
              final loc = locationController.text.trim();
              if (pumpName.isNotEmpty && id.isNotEmpty && loc.isNotEmpty) {
                final String baseUrl =
                    dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
                final String url =
                    "$baseUrl/api/farmer/${widget.farmId}/pumps/add";
                final headers = {
                  "Content-Type": "application/json",
                  "Cookie": sessionCookie ?? "",
                };
                final body = jsonEncode({
                  "pumpName": pumpName,
                  "pumpId": id,
                  "location": loc,
                });
                try {
                  final response =
                      await http.post(Uri.parse(url), headers: headers, body: body);
                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pump added successfully")),
                    );
                    Navigator.pop(context);
                    fetchPumps();
                  } else {
                    final errorData = jsonDecode(response.body);
                    final errorMessage =
                        errorData['message'] ?? errorData['error'] ?? 'Unknown error';
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to connect to server: $error")),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Dialog to show available Wi-Fi networks.
  void _showWiFiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Available Wi-Fi Networks"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Scanning for Wi-Fi networks..."),
                if (availableNetworks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableNetworks.length,
                    itemBuilder: (context, index) {
                      final network = availableNetworks[index];
                      return ListTile(
                        title: Text(network.ssid),
                        subtitle: Text("Signal: ${network.level}"),
                        onTap: () =>
                            debugPrint("Connecting to ${network.ssid}..."),
                      );
                    },
                  )
                else
                  const Text("No networks found."),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  // Send Wi-Fi credentials to a specific pump.
  Future<void> _sendWifiCredentials(String pumpId, String ssid, String password) async {
    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // IMPORTANT: Ensure your API route matches the one defined in your backend.
    final String url = "$baseUrl/api/farmer/farm/${widget.farmId}/pump/$pumpId/wifi/credentials";
  

    try {
      final response = await http.post(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? "",
      }, body: jsonEncode({"ssid": ssid, "password": password}));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wi-Fi credentials sent successfully")),
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error sending credentials: $errorMessage")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to connect to server: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.farmName} - Pump Details"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pumps.isNotEmpty
              ? ListView.builder(
                  itemCount: pumps.length,
                  itemBuilder: (context, index) {
                    final pump = pumps[index];
                    // For demonstration, default pump status is "ready".
                    final status = "ready";
                    return PumpWidget(
                      pump: pump,
                      farmId: widget.farmId,
                      onToggle: (status) {
                        // Additional logic if needed.
                      },
                      onTimerUpdate: (newTimer) {
                        setState(() {
                          pumps[index] = pump.copyWith(timer: newTimer);
                        });
                      },
                      onDelete: () => deletePump(pump.id),
                      onSendWiFiCredentials: (ssid, password) =>
                          _sendWifiCredentials(pump.id, ssid, password),
                      status: status,
                    );
                  },
                )
              : const Center(child: Text("No pumps found")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPumpDialog,
        backgroundColor: Colors.blue.shade200,
        child: const Icon(Icons.add),
      ),
    );
  }

  // _togglePumpStatus is delegated to PumpWidget.
  Future<void> _togglePumpStatus(String pumpId, bool status) async {}
}
