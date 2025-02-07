import 'package:flutter/material.dart';
import 'package:frontend/pages/admin_home.dart';
import 'package:frontend/pages/farm_page.dart';
import 'package:frontend/pages/news_page.dart';
import 'package:frontend/pages/otp_page.dart';
import 'package:frontend/pages/phone_page.dart';
import 'package:frontend/pages/pumps_in_farm_page.dart';
import 'package:frontend/pages/pumps_page.dart';
import 'package:frontend/pages/secretary_home.dart';
import 'package:frontend/pages/signup_page.dart';
import 'package:frontend/pages/user_select_page.dart';
import 'pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import './utils/routes.dart';


void main() {
  runApp(const MyApp());
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
        MyRoutes.pumpsfarmRoute: (context) => const PumpInFarm(),
       // MyRoutes.pumpsRoute: (context) => const PumpsPage() // routes map dont allow argument sending, so use materialPageRoute(dynamic pass argument) page me hi define kr diya , alag se yaha nhi batana. 
        MyRoutes.newsRoute:(context) => const NewsPage(),
        MyRoutes.adminHomeRoute:(context) => const AdminHome(),
        // MyRoutes.secretaryHomeRoute:(context) => const SecretaryHome(),
        // Remove this from routes and use Navigator.push for SecretaryHome
        MyRoutes.signupRoute:(context) => const SignupPage(),

      },
    );
  }
}
