import 'package:flutter/material.dart';
import '../models/pump_model.dart';

class PumpWidget extends StatelessWidget {
  final Pump pump;
  final ValueChanged<bool> onToggle;
  final ValueChanged<num> onTimerUpdate;
  final VoidCallback onDelete;

  const PumpWidget({
    super.key,
    required this.pump,
    required this.onToggle,
    required this.onTimerUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        onLongPress: () {
          // Show a confirmation dialog on long press for deletion.
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Delete Pump"),
              content: Text("Are you sure you want to delete Pump ${pump.id}?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: pump.status ? Colors.green : Colors.red,
          child: Text(
            pump.id,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Pump ${pump.id}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${pump.location}\nStatus: ${pump.status ? "ON" : "OFF"}\nTimer: ${pump.timer} minutes",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: pump.status,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withOpacity(0.5),
              onChanged: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.timer),
              onPressed: () => _showTimerDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    final TextEditingController timerController =
        TextEditingController(text: pump.timer.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Timer"),
          content: TextField(
            controller: timerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter timer (minutes)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final timerValue = num.tryParse(timerController.text) ?? 0;
                onTimerUpdate(timerValue);
                Navigator.pop(context);
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }
}
