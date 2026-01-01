import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/pet.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/pet_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/adoption_form_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/shelter/shelter_dashboard_screen.dart';
import 'screens/shelter/create_pet_screen.dart';
import 'screens/shelter/application_review_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize demo data
  final authService = AuthService();
  authService.initializeDemoData();
  
  final petService = PetService();
  petService.initializeDemoData();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        AppConstants.petDetailRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PetDetailScreen(petId: args['petId'] as String);
        },
        AppConstants.adoptionFormRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdoptionFormScreen(petId: args['petId'] as String);
        },
        AppConstants.myApplicationsRoute: (context) => const MyApplicationsScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
        AppConstants.editProfileRoute: (context) => const EditProfileScreen(),
        AppConstants.notificationsRoute: (context) => const NotificationsScreen(),
        AppConstants.shelterDashboardRoute: (context) => const ShelterDashboardScreen(),
        AppConstants.createPetRoute: (context) => const CreatePetScreen(),
        AppConstants.editPetRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CreatePetScreen(pet: args['pet'] as Pet);
        },
        AppConstants.applicationReviewRoute: (context) => const ApplicationReviewScreen(),
        AppConstants.adminDashboardRoute: (context) => const AdminDashboardScreen(),
      },
    );
  }
}
