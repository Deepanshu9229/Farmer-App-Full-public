import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tools/snacks.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  void initState() {
    super.initState();

    // Use a microtask to show the SnackBar after the widget builds
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

  //  a function to check if the number is registered
  bool isNumberRegistered(String number) {
    //  API call to your backend
    // For now, we'll just simulate it with a hardcoded value
    return false; // Assume the number is registered (false -> not registered)
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String userType = args?['userType'] ?? 'Unknown';
    final String otp = args?['otp'] ?? 'No OTP';

    final _formKey = GlobalKey<FormState>();
    final otpController = TextEditingController();

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
                    if (value != otp) {
                      return 'Incorrect OTP';
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Check if the OTP is correct
                    if (otpController.text == otp) {
                      // Simulate checking if the number is registered
                      if (!isNumberRegistered(otpController.text)) {
                        // If the number is not registered, navigate to the signup page
                        Navigator.pushReplacementNamed(context, '/signup');
                      } else {
                        // If the number is registered, navigate to the appropriate home page
                        if (userType == "Admin") {
                          Navigator.pushReplacementNamed(context, '/adminHome');
                        } else if (userType == "Secretary") {
                          Navigator.pushReplacementNamed(
                              context, '/secretaryHome');
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    }
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
