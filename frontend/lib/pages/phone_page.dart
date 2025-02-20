import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/routes.dart';
import 'package:frontend/utils/cookie_manager.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});
  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final formKey = GlobalKey<FormState>();
  String mobileNumber = "";

  Future<void> sendMobile(String mobile, BuildContext context) async {
    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/auth/enter-mobile";
    print("Connecting to: $url");
    print("Sending mobile: $mobile");

    final String otp = generateOTP();
    final payload = {
      "mobileNumber": mobile,
      "otp": otp,
    };
    print("Payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? ""
        },
        body: jsonEncode(payload),
      );
      print("Status: ${response.statusCode} | Body: ${response.body}");
      
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        sessionCookie = cookie;
        print("Session cookie updated in PhonePage: $sessionCookie");
      }

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.otpRoute,
          (Route<dynamic> route) => false,
          arguments: {'mobileNumber': mobile, 'otp': otp},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Status ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error: $e");
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // userType is available if needed
    String userType = args?['userType'] ?? 'unknown';

    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset("assets/images/phone.png", height: 240),
            const SizedBox(height: 30),
            const Text(
              "Phone Number Validation",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
