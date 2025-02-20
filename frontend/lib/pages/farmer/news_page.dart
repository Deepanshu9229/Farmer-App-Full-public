import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/pages/farmer/news_home.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
// splash screen reloading icon 2 second baad navigate karde neews pe
// set timer
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsHome(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Container(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            
            Image.asset(
              "assets/images/splash_pic.jpg",
              fit: BoxFit.cover,
              width: width,
              height: height * .5,
            ),
            SizedBox(
              height: height * 0.04,
            ),
            Text(
              "Top Headlines",
              style: GoogleFonts.poppins(
                   color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(
              height: height * 0.04,
            ),
            const SpinKitChasingDots(
              color: Colors.blue,
              size: 40,
            )
          ],
        ),
      ),
    );
  }
}
