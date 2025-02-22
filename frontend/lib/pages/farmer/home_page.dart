import 'package:flutter/material.dart';
import 'package:frontend/utils/routes.dart';
import 'package:frontend/widgets/drawer.dart';
import '../../widgets/weather_card.dart'; // Import WeatherCard
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/current_user.dart';


//Convert your HomePage to a ConsumerWidget so you can read the current user state.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current user from Riverpod provider.
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          "Farmer App",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        children: [
          // const SizedBox(height: 10.0),

          // Weather Card
          const WeatherCard(),

          // const SizedBox(height: 20.0),

          const SizedBox(
            height: 150,
            width: 150,
            child: ModelViewer(
              src: 'assets/3d/Tree.glb',
              alt: "A 3D model of a Tree",
              // ar: true,
              autoRotate: false,
              // cameraControls: true,
            ),
          ),

          // List of Cards
          Card(
            color: Colors.green.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            elevation: 4.0,
            child: ListTile(
              leading: const Icon(Icons.grass),
              title: const Text(
                "Farm Info",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Details about your farm."),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.farmRoute);
              },
            ),
          ),

          const SizedBox(height: 15.0),

          Card(
            color: Colors.blue.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            elevation: 4.0,
            child: ListTile(
              leading: const Icon(Icons.water),
              title: const Text(
                "Irrigation System",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Control your irrigation."),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.pumpsfarmRoute);
              },
            ),
          ),

          const SizedBox(height: 15.0),

          Card(
            color: Colors.yellow.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            elevation: 4.0,
            child: ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text(
                "News",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Check News."),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.newsRoute);
              },
            ),
          ),

          const SizedBox(height: 15.0),

          Card(
            color: Colors.pink.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            elevation: 4.0,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                "AI",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("For better decision making."),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Handle navigation or action here
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
