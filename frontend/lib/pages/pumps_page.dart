import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../widgets/pump_widget.dart';
import '../models/pump.dart'; // For PumpModel and Item classes
import 'package:wifi_scan/wifi_scan.dart'; // For Wi-Fi scanning
import 'package:permission_handler/permission_handler.dart'; // For requesting permissions

class PumpsPage extends StatefulWidget {
  final String farmName;

  const PumpsPage({super.key, required this.farmName});

  @override
  State<PumpsPage> createState() => _PumpsPageState();
}

class _PumpsPageState extends State<PumpsPage> {
  List<WiFiAccessPoint> availableNetworks = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadData();
  }

  // ✅ Request necessary permissions
  Future<void> requestPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print("Location permission granted.");
    } else {
      print("Location permission is required to scan Wi-Fi networks.");
    }
  }

  // ✅ Load pump data from JSON file
  Future<void> loadData() async {
    try {
      final pumpJson =
          await rootBundle.loadString("assets/files/PumpData.json");
      final decodedData = jsonDecode(pumpJson);
      var pumpsData = decodedData["pumpData"];

      PumpModel.items =
          List.from(pumpsData).map<Item>((item) => Item.fromMap(item)).toList();

      setState(() {});
    } catch (e) {
      print("Error loading pump data: $e");
    }
  }

  // ✅ Scan for available Wi-Fi networks
  Future<void> scanWiFiNetworks() async {
    // Check if scanning is allowed and handle the result correctly
    CanStartScan canStartScanResult = await WiFiScan.instance.canStartScan();

    if (canStartScanResult == CanStartScan.yes) {
      // If scanning is allowed, start the scan
      await WiFiScan.instance.startScan();
      WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        setState(() {
          availableNetworks = results;
        });
      });
    } else {
      // If scanning is not allowed, show a message or log the issue
      print(
          "Cannot start Wi-Fi scan. Ensure permissions are granted or conditions are met.");
    }
  }

  // ✅ Connect to a Wi-Fi network (dummy connection logic)
  Future<void> connectToNetwork(String ssid) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connecting to $ssid...")),
    );
    // Add real connection logic here
  }

  // Wi-Fi Scan Dialog
void _showWiFiDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Available Wi-Fi Networks"),
        content: SingleChildScrollView( // Wrap content in SingleChildScrollView for scrollability
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400), // Limit height
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Scanning for Wi-Fi networks..."),
                if (availableNetworks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Disable internal scroll
                    itemCount: availableNetworks.length,
                    itemBuilder: (context, index) {
                      final network = availableNetworks[index];
                      return ListTile(
                        title: Text(network.ssid),
                        subtitle: Text("Signal: ${network.level}"),
                        onTap: () => connectToNetwork(network.ssid),
                      );
                    },
                  ),
                if (availableNetworks.isEmpty)
                  const Text("No networks found."),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

  // ✅ Add new pump dialog
  void _addNewPump() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Pump"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pump ID"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: timerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Timer (minutes)"),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    const Text("Scan Wifi to Connect"),
                    IconButton(
                      icon: const Icon(Icons.wifi),
                      onPressed: (){
                        scanWiFiNetworks();  // Trigger Wi-Fi scan
                       _showWiFiDialog();   // Show the Wi-Fi dialog
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final id = int.tryParse(idController.text) ?? 0;
                final location = locationController.text.trim();
                final timer = num.tryParse(timerController.text) ?? 0;

                if (id > 0 && location.isNotEmpty) {
                  setState(() {
                    PumpModel.items.add(
                      Item(
                        id: id,
                        location: location,
                        status: false,
                        timer: timer,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.farmName} - Pump Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body
          : PumpModel.items.isNotEmpty
              ? ListView.builder(
                  itemCount: PumpModel.items.length,
                  itemBuilder: (context, index) {
                    return PumpWidget(
                      pump: PumpModel.items[index],
                      onToggle: (status) {
                        setState(() {
                          PumpModel.items[index] = Item(
                            id: PumpModel.items[index].id,
                            location: PumpModel.items[index].location,
                            status: status,
                            timer: PumpModel.items[index].timer,
                          );
                        });
                      },
                      onTimerUpdate: (newTimer) {
                        setState(() {
                          PumpModel.items[index] = Item(
                            id: PumpModel.items[index].id,
                            location: PumpModel.items[index].location,
                            status: PumpModel.items[index].status,
                            timer: newTimer,
                          );
                        });
                      },
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 50),
        child: FloatingActionButton(
          onPressed: _addNewPump,
          backgroundColor: Colors.blue.shade200,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
