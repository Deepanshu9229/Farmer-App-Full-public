import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/cookie_manager.dart';
import '../tools/snacks.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Optionally, show a SnackBar with the OTP (for demo purposes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final otp = args?['otp'] ?? 'No OTP';
      Snacks.showSnackBar(
        context,
        message: "Your OTP is $otp",
        color: Colors.green,
        leadingIcon: Icons.security,
      );
    });
  }

  Future<void> verifyOtp() async {
    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/auth/verify-otp";
    final headers = {"Content-Type": "application/json", "Cookie": sessionCookie ?? ""};
    final body = jsonEncode({"otp": otpController.text});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        // Capture the session cookie from the response headers
        final cookie = response.headers['set-cookie'];
        if (cookie != null) {
          sessionCookie = cookie;
          print("Session cookie set: $sessionCookie");
        }
        // Parse the response to get a redirect URL or user type
        final responseData = jsonDecode(response.body);
        final redirectUrl = responseData['redirectUrl'] as String? ?? "";

        // Navigate based on the redirectUrl returned by your backend
        if (redirectUrl.contains('admin')) {
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else if (redirectUrl.contains('secretary')) {
          Navigator.pushReplacementNamed(context, '/secretaryHome');
        } else if (redirectUrl.contains('signup')) {
          Navigator.pushReplacementNamed(context, '/signup');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP verification failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // We no longer need to compare client-side since the backend verifies the OTP.
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                "assets/images/otp.png",
                height: 180,
              ),
              const SizedBox(height: 40),
              const Text(
                "OTP Verification",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: otpController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Enter OTP",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff008B38),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    verifyOtp();
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
