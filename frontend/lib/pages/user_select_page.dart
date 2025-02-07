import 'package:flutter/material.dart';
// import 'package:frontend/pages/phone_page.dart';
import '../utils/routes.dart';

class UserSelectPage extends StatelessWidget {
  const UserSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 150),
            Image.asset('assets/images/user.png', height: 200),
            const SizedBox(height: 50),
            const Text(
              "Select UserType",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150, height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.phoneRoute, arguments:{'userType' : 'Admin'});
                      },
                      child: const Text(
                        "Admin",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 150, height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.phoneRoute, arguments: {'userType' : 'Secretary'});
                      },
                      child: const Text(
                        "Secretary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150, height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.phoneRoute, arguments: {'userType':'Farmer'});
                      },
                      child: const Text(
                        "Farmer",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
