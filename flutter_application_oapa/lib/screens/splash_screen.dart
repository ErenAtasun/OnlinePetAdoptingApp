import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Wait for auth provider to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if user is logged in
    if (authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else {
      // Check if onboarding was shown (in real app, use SharedPreferences)
      Navigator.of(context).pushReplacementNamed(AppConstants.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find your perfect companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

