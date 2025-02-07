import 'package:flutter/material.dart';
import '../models/pump.dart';

class PumpWidget extends StatelessWidget {
  final Item pump;
  final ValueChanged<bool> onToggle;
  final ValueChanged<num> onTimerUpdate;

  const PumpWidget({
    super.key,
    required this.pump,
    required this.onToggle,
    required this.onTimerUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pump.status ? Colors.green : Colors.red,
          child: Text(
            pump.id.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Pump ${pump.id}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${pump.location}\n"
          "Status: ${pump.status ? "ON" : "OFF"}\n"
          "Timer: ${pump.timer} minutes",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Switch(
          value: pump.status,
          activeColor: Colors.green, // Change active color
          inactiveThumbColor: Colors.red, // Change inactive thumb color
          inactiveTrackColor: Colors.red.withOpacity(0.5), // Change inactive track color
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

  // Show a dialog to set the timer
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
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final timerValue = num.tryParse(timerController.text) ?? 0;
                onTimerUpdate(timerValue); // Update the timer value
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }
}
