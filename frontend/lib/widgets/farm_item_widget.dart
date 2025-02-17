import 'package:flutter/material.dart';
import '../models/farm.dart'; 
import '../utils/routes.dart';

class FarmItemWidget extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete; // Callback for deletion

  const FarmItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        onLongPress: () {
          // Show confirmation dialog on long press
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Delete Farm"),
              content: Text("Are you sure you want to delete '${item.name}'?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    onDelete(); // Execute delete callback
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
          backgroundColor: Colors.green,
          child: Text(
            item.name.isNotEmpty ? item.name[0] : '',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Location: ${item.location}\nPincode: ${item.pincode}\nAddress: ${item.address}",
        ),
        // trailing: const Icon(Icons.arrow_forward_ios_rounded),
        // onTap: () {
        //   // Navigate to pump page
        //   Navigator.pushNamed(context, MyRoutes.pumpsfarmRoute, arguments: {
        //     'farmId': item.id,
        //     'farmName': item.name,
        //   });
        // },
      ),
    );
  }
}
