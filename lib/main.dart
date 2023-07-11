import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screen/login_screen.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Your App",
    home: DelayedSplashScreen(),
  ));
}

class DelayedSplashScreen extends StatefulWidget {
  const DelayedSplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DelayedSplashScreenState();
}

class _DelayedSplashScreenState extends State<DelayedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLoginScreen();
  }

  void _navigateToLoginScreen() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (ctx) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red[200]!,
              Colors.red[400]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              "image.jpg",
              width: 300,
              height: 150,
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}