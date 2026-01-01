import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/pets/presentation/pet_list_page.dart';
import 'features/pets/presentation/pet_detail_page.dart';
import 'features/pets/presentation/create_edit_pet_page.dart';
import 'features/search/presentation/search_page.dart';
import 'features/adoption/presentation/adoption_form_page.dart';
import 'features/applications/presentation/my_applications_page.dart';
import 'features/shelter/presentation/shelter_dashboard_page.dart';
import 'features/shelter/presentation/applications_review_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/notifications/presentation/notifications_page.dart';
import 'core/providers/auth_provider.dart';

class PetAdoptApp extends ConsumerWidget {
  const PetAdoptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final publicRoutes = [
          '/splash',
          '/onboarding',
          '/login',
          '/register',
          '/',
          '/search',
        ];
        
        final isPublicRoute = publicRoutes.contains(state.matchedLocation) ||
            state.matchedLocation.startsWith('/pets/');
        final isAuthed = authState.isAuthenticated;

        // Allow access to public routes (browsing pets)
        if (isPublicRoute) {
          return null;
        }

        // Redirect to login if not authenticated for protected routes
        if (!isAuthed) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const PetListPage(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/pets/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PetDetailPage(petId: id);
          },
        ),
        GoRoute(
          path: '/adopt/:petId',
          builder: (context, state) {
            final petId = state.pathParameters['petId']!;
            return AdoptionFormPage(petId: petId);
          },
        ),
        GoRoute(
          path: '/applications',
          builder: (context, state) => const MyApplicationsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/shelter/dashboard',
          builder: (context, state) => const ShelterDashboardPage(),
        ),
        GoRoute(
          path: '/shelter/applications',
          builder: (context, state) => const ApplicationsReviewPage(),
        ),
        GoRoute(
          path: '/shelter/pets/create',
          builder: (context, state) => const CreateEditPetPage(),
        ),
        GoRoute(
          path: '/shelter/pets/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CreateEditPetPage(petId: id);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PetAdopt',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}
