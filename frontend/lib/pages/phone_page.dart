import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For inputFormatters
import 'package:frontend/utils/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/routes.dart';
import 'package:frontend/utils/cookie_manager.dart'; // Import cookie manager

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final formKey = GlobalKey<FormState>();
  String mobileNumber = "";

  Future<void> sendMobile(String mobile, BuildContext context) async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/auth/enter-mobile";

    print("Attempting to connect to: $url");
    print("Sending mobile: $mobile");

    // Generate OTP once and store it in a variable.
    final String otp = generateOTP();
    final payload = {
      "mobileNumber": mobile,
      "otp": otp,
    };
    print("Sending payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        // Include the previously stored cookie so that the same session is used.
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? ""
        },
        body: jsonEncode(payload),
      );
      print("Response: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      // Capture session cookie from /enter-mobile response (if updated).
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        sessionCookie = cookie;
        print("Session cookie captured in PhonePage: $sessionCookie");
      }

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.otpRoute,
          (Route<dynamic> route) => false, //clears entire stack
          arguments: {'mobileNumber': mobile, 'otp': otp},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Status ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error detail: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: ${e.toString()}")),
      );
    }
  }

  String generateOTP() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // userType is available if needed, but we don't pass it forward to OTP page because the session should have it.
    String userType = args?['userType'] ?? 'unknown';

    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset(
              "assets/images/phone.png",
              height: 240,
            ),
            const SizedBox(height: 30),
            const Text(
              "Phone Number Validation",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 80.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          mobileNumber = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 10) {
                          return 'Phone Number must be 10 digits';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter Phone Number",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff008B38),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          sendMobile(mobileNumber, context);
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
