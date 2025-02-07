import 'package:flutter/material.dart';

class Snacks {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color color = Colors.green,
    IconData? leadingIcon,
    Duration duration = const Duration(seconds: 5),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (leadingIcon != null) Icon(leadingIcon, color: Colors.white),
          if (leadingIcon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: behavior,
      margin: behavior == SnackBarBehavior.floating ? margin : null,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
