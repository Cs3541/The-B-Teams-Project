import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'The Sweet Dreams App',
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}