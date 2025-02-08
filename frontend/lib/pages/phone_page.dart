import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For inputFormatters
import 'package:frontend/utils/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/routes.dart';


class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final formKey = GlobalKey<FormState>();
  String mobileNumber = "";

  Future<void> sendMobile(String mobile, BuildContext context )async{
    final String baseUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:4000';
    final String url = "$baseUrl/api/auth/enter-mobile";

    print("Attempting to connect to : $url");
    print("sending mobile  : $mobile");

    final String otp = generateOTP(); // Generate OTP
    final payload = {
      "mobile": mobile,
      "otp": otp,
    };
    print("Sending payload: ${jsonEncode(payload)}"); // Add this line to debug

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"content-Type" : "application/json"},
        body: jsonEncode({
          "mobileNumber":mobile,
          "otp":generateOTP(),
        }),
      );
      print("Response : ${response.statusCode}");
      print("response body : ${response.body}");

      if(response.statusCode == 200){
        Navigator.pushNamed(context, MyRoutes.otpRoute, arguments: {'mobileNumber' : mobile, 'otp' : otp});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Status ${response.statusCode}")),
        );
      }
      
    } catch (e) {
      print("errro detail : $e");
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connection error: ${e.toString()}")),
      );
    }

  }

  generateOTP(){
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String userType = args?['userType'] ?? 'Unknown';

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