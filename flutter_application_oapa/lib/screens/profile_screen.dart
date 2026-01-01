import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not logged in'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppConstants.loginRoute);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                      if (user.phoneNumber != null)
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(user.phoneNumber!),
                        ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Member Since'),
                        subtitle: Text(_formatDate(user.createdAt)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (user.role == UserRole.adopter)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('My Applications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppConstants.myApplicationsRoute);
                      },
                    ),
                  ),
                if (user.role == UserRole.shelter)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: const Text('Shelter Dashboard'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppConstants.shelterDashboardRoute);
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppConstants.loginRoute,
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

