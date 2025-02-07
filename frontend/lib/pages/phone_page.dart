import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For inputFormatters
import 'package:frontend/utils/routes.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  generateOTP(){
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String userType = args?['userType'] ?? 'Unknown';

    final _formKey = GlobalKey<FormState>();

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
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 10) {
                          return 'Phone Number must be 10 digits';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter Phone Number",
                        // border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Allow digits only
                        LengthLimitingTextInputFormatter(
                            10), // Limit input to 10 digits
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff008B38),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final otp = generateOTP();
                          Navigator.pushReplacementNamed(context, MyRoutes.otpRoute,
                              arguments: {'userType': userType, 'otp' : otp});
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
