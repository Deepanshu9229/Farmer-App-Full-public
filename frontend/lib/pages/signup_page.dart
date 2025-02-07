import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height : 80),
            Image.asset("assets/images/signup.png", height: 240),
            const Text("SignUp Please!", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),),
          ],
        ),
      ),
    );
  }
}
