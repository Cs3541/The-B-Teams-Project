import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'views/main_navigation.dart';
import 'presenters/settings_presenter.dart';
import 'views/settings_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SleepAppTracker());
}

class SleepAppTracker extends StatefulWidget {
  const SleepAppTracker({super.key});

  @override
  State<SleepAppTracker> createState() => _SleepAppTrackerState();
}

class _SleepAppTrackerState extends State<SleepAppTracker> {
  final _settings = SettingsPresenter();

  @override
  void initState() {
    super.initState();
    _settings.load().catchError((Object _) {
      // Keep the default background if local preferences are unavailable.
    });
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      presenter: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, child) => MaterialApp(
          title: 'Sweet Dreams',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: _settings.background.color,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      ); //Launches bottom nav app
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
              'The B Team Presents...',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
