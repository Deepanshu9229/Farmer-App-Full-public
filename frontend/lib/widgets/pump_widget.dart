import 'package:flutter/material.dart';
import '../models/pump_model.dart';
import '../services/mqtt_service.dart';

class PumpWidget extends StatefulWidget {
  final Pump pump;
  final void Function(bool) onToggle;
  final void Function(num) onTimerUpdate;
  final void Function() onDelete;
  final String status;
  final void Function(String, String) onSendWiFiCredentials; // New callback

  const PumpWidget({
    Key? key,
    required this.pump,
    required this.onToggle,
    required this.onTimerUpdate,
    required this.onDelete,
    required this.status,
    required this.onSendWiFiCredentials, // Receive new callback
  }) : super(key: key);

  @override
  State<PumpWidget> createState() => _PumpWidgetState();
}

class _PumpWidgetState extends State<PumpWidget> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey; // Default color
    String statusText = "Disconnected";

    switch (widget.status) {
      case "ready":
        statusColor = Colors.green;
        statusText = "Ready";
        break;
      case "connecting":
        statusColor = Colors.orange;
        statusText = "Connecting...";
        break;
      case "disconnected":
        statusColor = Colors.red;
        statusText = "Disconnected";
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor, // Use statusColor here
          child: Text(
            widget.pump.pumpName.isNotEmpty ? widget.pump.pumpName[0].toUpperCase() : '',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Pump: ${widget.pump.pumpName}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${widget.pump.location}\nStatus: $statusText\nTimer: ${widget.pump.timer} min", // Use statusText
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Wi-Fi Configuration", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(labelText: "SSID"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSendWiFiCredentials(
                      _ssidController.text,
                      _passwordController.text,
                    );
                  },
                  child: const Text("Send Wi-Fi Credentials"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Switch(
                      value: widget.pump.status,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (widget.status == "ready") ? (value) => widget.onToggle(value) : null, // Disable switch if not ready
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer),
                      onPressed: () => _showTimerDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pump"),
        content: Text("Delete pump ${widget.pump.pumpName} (ID: ${widget.pump.id})?"), // Access widget.pump
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(); // Access widget.onDelete
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.pump.timer.toString()); // Access widget.pump

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Timer"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Minutes"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final timerValue = num.tryParse(controller.text) ?? 0;
              widget.onTimerUpdate(timerValue); // Access widget.onTimerUpdate
              Navigator.pop(context);
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }
}