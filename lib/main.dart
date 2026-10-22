import 'package:flutter/material.dart';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../views/main_navigation.dart'; //use bottom nav screen


void main() {
  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),

    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationScreen())); //Launches bottom nav app
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,        
          children: [
              Text(
                'Homework Tracker',
                style: TextStyle(
                  fontSize: 24, 
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
              LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 50,
              ),
            ],
      ),
      ),
    );
  }
}