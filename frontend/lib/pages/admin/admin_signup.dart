import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/cookie_manager.dart';
import 'package:frontend/utils/routes.dart';
import 'package:frontend/models/current_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminSignupPage extends ConsumerStatefulWidget {
  const AdminSignupPage({super.key});

  @override
  _AdminSignupPageState createState() => _AdminSignupPageState();
}

class _AdminSignupPageState extends ConsumerState<AdminSignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String baseUrl =
        dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    // Ensure the URL matches your backend admin signup route.
    final String url = "$baseUrl/api/admin/signup";
    final headers = {
      "Content-Type": "application/json",
     // Include the session cookie so that the backend can access req.session.mobileNumber
      "Cookie": sessionCookie ?? ""
    };

    final body = jsonEncode({
      "name": nameController.text,
      "mobileNumber": mobileNumberController.text,
      "city": cityController.text,
      "pincode": pincodeController.text,
      "residentialAddress": addressController.text,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 201) {
        // Capture the session cookie from the response headers.
        final cookie = response.headers['set-cookie'];
        if (cookie != null) {
          sessionCookie = cookie;
          print("Session cookie captured in AdminSignupPage: $sessionCookie");
        }

        final responseData = jsonDecode(response.body);
        print("Admin ID: ${responseData['adminId']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Update current user state via Riverpod.
        ref.read(currentUserProvider.notifier).setUser(
          User(
            name: nameController.text,
            mobileNumber: mobileNumberController.text,
          ),
        );

        // Navigate to the Admin Home page, clearing the navigation stack.
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.adminHomeRoute,
          (Route<dynamic> route) => false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['message']}")),
        );
      }
    } catch (error) {
      print("Signup Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    }
  }

  Widget textField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value!.isEmpty ? "Please enter your $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset("assets/images/signup.png", height: 230),
            const Text("Admin SignUp Please!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  textField("Full Name", nameController),
                  textField("Mobile Number", mobileNumberController,
                      keyboardType: TextInputType.phone),
                  textField("City", cityController),
                  textField("Pincode", pincodeController,
                      keyboardType: TextInputType.number),
                  textField("Address", addressController),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff008B38),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: signupUser,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
