import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:frontend/models/pump_model.dart';
import 'package:frontend/widgets/pump_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:frontend/services/mqtt_service.dart'; // Import MQTTService

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
  final MQTTService _mqttService = MQTTService(); // Initialize MQTTService
  final Map<String, String> _pumpStatuses = {}; // Store pump statuses

  @override
  void initState() {
    super.initState();
    requestPermissions();
    fetchPumps();
    connectMQTT(); // Call connectMQTT here
  }

  // Request necessary permissions for Wi-Fi scanning.
  Future<void> requestPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      debugPrint("Location permission granted.");
    } else {
      debugPrint("Location permission is required to scan Wi-Fi networks.");
    }
  }

  //-----mqtt
  // Connect to MQTT broker and subscribe to pump status updates.
    Future<void> connectMQTT() async {
    await _mqttService.connect();

    // Subscribe to individual pump status topics.
    for (var pump in pumps) {
      final topic = "farm/${widget.farmId}/pump/${pump.id}/status";
      _mqttService.subscribe(topic);
    }

    _mqttService.messageStream.listen((messages) {
      for (var message in messages) {
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (message.payload as MqttPublishMessage).payload.message,
        );
        final pumpId = topic.split('/')[3]; // Extract pumpId from topic

        setState(() {
          _pumpStatuses[pumpId] = payload; // Store the status
        });
        debugPrint("Received status for pump $pumpId: $payload");
      }
    });
  }

  // Fetch pumps for the selected farm from the backend API.
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
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Unable to fetch pumps")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
     if (mounted) {
      setState(() {
        isLoading = false;
      });

      connectMQTT();
    }
  }
  

  // Delete a pump using the backend API.
  Future<void> deletePump(String pumpId) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/${widget.farmId}/pumps/$pumpId";
    final headers = {
      "Content-Type": "application/json",
      "Cookie": sessionCookie ?? "",
    };

    debugPrint("Deleting pump with id: $pumpId");
    debugPrint("DeletePump URL: $url");
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
      debugPrint("DeletePump error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to connect to server: $error")));
    }
  }

  // Display a dialog to add a new pump via backend API.
  void _showAddPumpDialog() {
    final TextEditingController pumpNameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    // final TextEditingController timerController = TextEditingController();

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
              // TextField(
              //   controller: timerController,
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(labelText: "Timer (minutes)"),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    const Text("Scan Wi-Fi to Connect"),
                    IconButton(
                      icon: const Icon(Icons.wifi),
                      onPressed: () {
                        _showWiFiDialog();
                      },
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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final pumpName = pumpNameController.text.trim();
              final id = idController.text.trim();
              final loc = locationController.text.trim();
              // final timer = num.tryParse(timerController.text) ?? 0;
              if (id.isNotEmpty && loc.isNotEmpty && pumpName.isNotEmpty) {
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
                  // "timer": timer,
                });
                try {
                  final response = await http.post(Uri.parse(url),
                      headers: headers, body: body);
                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pump added successfully")),
                    );
                    Navigator.pop(context);
                    fetchPumps();
                  } else {
                    final errorData = jsonDecode(response.body);
                    final errorMessage = errorData['message'] ??
                        errorData['error'] ??
                        'Unknown error';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $errorMessage")),
                    );
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Failed to connect to server: $error")),
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

  // Display a dialog showing scanned Wi-Fi networks.
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
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

 // Method to send WiFi credentials to a specific pump
  Future<void> _sendWifiCredentials(String pumpId, String ssid, String password) async {
    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/${widget.farmId}/pumps/$pumpId/wifi"; // Corrected URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "",
        },
        body: jsonEncode({
          "ssid": ssid,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wi-Fi credentials sent successfully")),
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending credentials: $errorMessage")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server: $error")),
      );
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
                     final status = _pumpStatuses[pump.id] ?? "disconnected";  // Get status, default to disconnected
                    return PumpWidget(
              pump: pump,
              status: status,  //Here is the fix for missing status value
              onToggle: (status) {
                _togglePumpStatus(pump.id, status);  // Call new toggle function
              },
              onTimerUpdate: (newTimer) {
                setState(() {
                  pumps[index] = pump.copyWith(timer: newTimer);
                });
              },
              onDelete: () {
                deletePump(pump.id);
              },
              onSendWiFiCredentials: (ssid, password) {  // Pass callback
                _sendWifiCredentials(pump.id, ssid, password);
              },
            );
          },
      )
          : const Center(child: Text("No pumps found.")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPumpDialog,
        backgroundColor: Colors.blue.shade200,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _togglePumpStatus(String pumpId, bool newStatus) {
    final String topic = "farm/${widget.farmId}/pump/$pumpId/led/control";
    final String message = newStatus ? "on" : "off";
    _mqttService.publish(topic, message);
    //Update pump status locally in flutter
    setState(() {
      pumps = pumps.map((pump) {
        if (pump.id == pumpId) {
          return pump.copyWith(status: newStatus);
        }
        return pump;
      }).toList();
    });
  }
}