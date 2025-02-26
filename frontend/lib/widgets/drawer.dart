import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/current_user.dart';
import 'package:frontend/utils/routes.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current user from Riverpod.
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? 'Unknown User';
    final mobileNumber = user?.mobileNumber ?? 'N/A';

    return Drawer(
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
                userName,
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
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text(
              "Home",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              print(user?.role?.toLowerCase());

              // Dynamically navigate based on the user's type.
              if (user != null) {
                switch (user?.role?.toLowerCase()) {
                  case 'farmer':
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.homeRoute, (route) => false);
                    break;
                  case 'secretary':
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.secretaryHomeRoute, (route) => false);
                    break;
                  case 'admin':
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.adminHomeRoute, (route) => false);
                    break;
                  default:
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.homeRoute, (route) => false);
                }
              }
            },
          ),
            
          ListTile(
            leading: const Icon(Icons.mail, color: Colors.black),
            title: const Text(
              "Contact",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Implement contact functionality or navigation.
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text(
              "Signout",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Clear the user state and navigate to the user select page.
              ref.read(currentUserProvider.notifier).clearUser();
              Navigator.pushNamedAndRemoveUntil(
                  context, MyRoutes.userSelectRoute, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
