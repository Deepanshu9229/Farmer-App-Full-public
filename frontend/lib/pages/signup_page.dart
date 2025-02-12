import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to get user input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/farmer/signup";
    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({
      "name": nameController.text,
      "mobileNumber": mobileNumberController.text,
      "city": cityController.text,
      "pincode": pincodeController.text,
      "residentialAddress": addressController.text,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),

        );

        // Navigate to home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['message']}")),
        );
      }
    } catch (error) {
      print("Signup Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server")),
      );
    }
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
            const Text("SignUp Please!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  textField("Full Name", nameController),
                  textField("Mobile Number", mobileNumberController, keyboardType: TextInputType.phone),
                  textField("City", cityController),
                  textField("Pincode", pincodeController, keyboardType: TextInputType.number),
                  textField("Address", addressController),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff008B38),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget textField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
      ),
    );
  }
}
