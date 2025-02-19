import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/routes.dart';

class MyDrawer extends StatelessWidget {
  final String farmerName;
  final String mobileNumber;

  const MyDrawer({
    Key? key,
    required this.farmerName,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // Optionally, set a background color here
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.green,
                ),
                accountName: Text(
                  farmerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  mobileNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/blabla.jpeg"),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.home, color: Colors.black),
              title: const Text(
                "Home",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to home page
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.mail_solid, color: Colors.black),
              title: const Text(
                "Contact",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to contact page or show contact info
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.arrow_uturn_left_circle, color: Colors.black),
              title: const Text(
                "Signout",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Handle signout: clear session data, then navigate to login screen.
                Navigator.pushNamedAndRemoveUntil(context, MyRoutes.userSelectRoute, (route) => false);
              },
            ),
          ],
        ),
    );
  }
}
