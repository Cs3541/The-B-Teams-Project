
import 'package:flutter/material.dart';
import 'app_top_bar.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Daily Check List'),
      body: const SizedBox.expand(),
    );
  }
}
