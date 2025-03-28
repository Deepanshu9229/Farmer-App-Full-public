import 'package:flutter/material.dart';
import '../models/pump_model.dart';
import '../services/mqtt_service.dart';

class PumpWidget extends StatefulWidget {
  final Pump pump;
  final String farmId;
  final void Function(bool) onToggle;
  final void Function(num) onTimerUpdate;
  final void Function() onDelete;
  final String status;
  final void Function(String, String) onSendWiFiCredentials;

  const PumpWidget({
    Key? key,
    required this.pump,
    required this.farmId,
    required this.onToggle,
    required this.onTimerUpdate,
    required this.onDelete,
    required this.status,
    required this.onSendWiFiCredentials,
  }) : super(key: key);

  @override
  State<PumpWidget> createState() => _PumpWidgetState();
}

class _PumpWidgetState extends State<PumpWidget> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late MQTTService mqttService;
  String _localStatus = 'disconnected';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    mqttService = MQTTService();
    _initMQTT();
  }

  Future<void> _initMQTT() async {
    await mqttService.connect();
    _subscribeToUpdates();
    setState(() => _isConnected = mqttService.isConnected);
  }

  void _subscribeToUpdates() {
    final statusTopic = 'farm/${widget.farmId}/pump/${widget.pump.id}/status';
    mqttService.subscribe(statusTopic, (payload) {
      if (mounted) {
        setState(() => _localStatus = payload.trim().toLowerCase());
      }
    });
  }

  void _togglePump(bool value) {
    if (!_isConnected) return;

    // Immediately update local state
    setState(() {
      _localStatus = value ? 'on' : 'off';
    });

    final controlTopic = 'farm/${widget.farmId}/pump/${widget.pump.id}/control';
    final newState = value ? 'ON' : 'OFF';
    mqttService.publish(controlTopic, newState);
    widget.onToggle(value);
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
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
      default:
        statusColor = Colors.grey;
        statusText = "Unknown";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            widget.pump.pumpName.isNotEmpty
                ? widget.pump.pumpName[0].toUpperCase()
                : '',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Pump: ${widget.pump.pumpName}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${widget.pump.location}\nStatus: ${_localStatus.toUpperCase()}\nTimer: ${widget.pump.timer} min",
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Wi-Fi Configuration",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                        _ssidController.text, _passwordController.text);
                  },
                  child: const Text("Send Wi-Fi Credentials"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Switch(
                      value: _localStatus == 'on',
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged:
                          (widget.status == "ready") ? _togglePump : null,
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
        content: Text(
            "Delete pump ${widget.pump.pumpName} (ID: ${widget.pump.id})?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    final controller =
        TextEditingController(text: widget.pump.timer.toString());
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final timerValue = num.tryParse(controller.text) ?? 0;
              widget.onTimerUpdate(timerValue);
              mqttService.publish("pump/timer", timerValue.toString());
              Navigator.pop(context);
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }
}
