
import 'package:flutter/material.dart';
import 'app_top_bar.dart';

class FeaturedArticlesScreen extends StatelessWidget {
  const FeaturedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Featured Articles'),
      body: const Center(
        child: SizedBox(),
      ),
    );
  }
}
