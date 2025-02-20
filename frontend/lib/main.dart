import 'package:flutter/material.dart';
import 'package:frontend/pages/admin/admin_home.dart';
import 'package:frontend/pages/farmer/farm_page.dart';
import 'package:frontend/pages/farmer/news_page.dart';
import 'package:frontend/pages/otp_page.dart';
import 'package:frontend/pages/phone_page.dart';
import 'package:frontend/pages/farmer/pumps_in_farm_page.dart';
import 'package:frontend/pages/farmer/pumps_page.dart';
import 'package:frontend/pages/secretary/secretary_home.dart';
import 'package:frontend/pages/farmer/signup_page.dart';
import 'package:frontend/pages/user_select_page.dart';
import 'pages/farmer/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import './utils/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:frontend/pages/secretary/secretary_signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure async operations complete
  await dotenv.load(fileName: ".env"); // Load .env file

  runApp(const ProviderScope(child: MyApp())); //Wrap Your App with ProviderScope 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.green),
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      //  initialRoute: MyRoutes.homeRoute,
      initialRoute: MyRoutes.userSelectRoute,
      // initialRoute:  MyRoutes.signupRoute,
      routes: {
        // "/": (context) => const UserSelectPage(),
        MyRoutes.userSelectRoute: (context) => const UserSelectPage(),
        MyRoutes.phoneRoute: (context) => const PhonePage(),
        MyRoutes.otpRoute: (context) => const OtpPage(),
        MyRoutes.homeRoute: (context) => const HomePage(),
        MyRoutes.farmRoute: (context) => const FarmPage(),
        MyRoutes.pumpsfarmRoute: (context) => const PumpInFarmPage(),
        // MyRoutes.pumpsRoute: (context) =>  PumpsPage(), // routes map dont allow argument sending, so use materialPageRoute(dynamic pass argument) page me hi define kr diya , alag se yaha nhi batana.
        MyRoutes.pumpsRoute: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map;
          return PumpsPage(
            farmId: args['farmId'].toString(),
            farmName: args['farmName'] ?? 'Pumps',
            // farmerId: 'current_farmer_id',
          );
        },
         MyRoutes.secretaryHomeRoute: (context) => SecretaryHome(area: "YourArea"),
         MyRoutes.secretarySignupRoute: (context) => const SecretarySignupPage(),

        MyRoutes.newsRoute: (context) => const NewsPage(),
        MyRoutes.adminHomeRoute: (context) => const AdminHome(),
        // MyRoutes.secretaryHomeRoute:(context) => const SecretaryHome(),
        // Remove this from routes and use Navigator.push for SecretaryHome
        MyRoutes.signupRoute: (context) => const SignupPage(),
      },
    );
  }
}
