import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // Controllers to get user input
    final TextEditingController nameController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController pincodeController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents keyboard from hiding inputs
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Hides keyboard when scrolling
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Signup image
            Image.asset("assets/images/signup.png", height: 230),

            // Heading
            const Text(
              "SignUp Please!",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
            ),
            const SizedBox(height: 10),

            // Form with padding
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your name" : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: "City"),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your city" : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: pincodeController,
                      decoration: const InputDecoration(labelText: "Pin Code"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your pin code" : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                   
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your address" : null,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
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
                        print("Name: ${nameController.text}");
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                      
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
