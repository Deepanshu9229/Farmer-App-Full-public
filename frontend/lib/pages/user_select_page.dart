import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/routes.dart';
import 'package:frontend/utils/cookie_manager.dart';

class UserSelectPage extends StatelessWidget {
  const UserSelectPage({super.key});

  Future<void> sendUserType(String userType, BuildContext context) async {
    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/auth/select-user-type";
    print("Connecting to: $url");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userType": userType.toLowerCase()}),
      );
      print("Status: ${response.statusCode} | Body: ${response.body}");
      
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        sessionCookie = cookie;
        print("Session cookie captured: $sessionCookie");
      }

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.phoneRoute,
          (Route<dynamic> route) => false,
          arguments: {'userType': userType.toLowerCase()},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Unable to select user type")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/images/user.png', height: 200),
              const SizedBox(height: 50),
              const Text(
                "Select UserType",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  _userTypeButton(context, "Admin"),
                  _userTypeButton(context, "Secretary"),
                  _userTypeButton(context, "Farmer"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _userTypeButton(BuildContext context, String userType) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 150,
        height: 50,
        child: ElevatedButton(
          onPressed: () => sendUserType(userType, context),
          child: Text(
            userType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
