import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../principal/accueil.dart';
import 'login.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool hasInternet = true; // Assume internet is initially available

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  Future<void> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        hasInternet = false;
      });
    }

    // Delay for 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // Navigate to the next page or perform other actions based on internet availability
    if (hasInternet) {
      print("Navigating to Login page...");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');
      if (userId == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Accueil()),
        );
      }
    } else {
      print("No internet, handle accordingly...");
      // Navigate to the next page or perform actions when internet is not available
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            Image.asset(
              'assets/logo.png',
              width: 190,
              height: 190,
              // Adjust width and height according to your logo size
            ),
            SizedBox(height: 30),
            // Loading animation
            SpinKitWave(
              color: Color.fromRGBO(249, 175, 24, 1), // Change the color as needed
              size: 40.0, // Adjust the size as needed
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
