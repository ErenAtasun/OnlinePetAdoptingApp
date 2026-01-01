import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/adoption_service.dart';
import '../services/pet_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PetService _petService = PetService();
  late AdoptionService _adoptionService;
  late NotificationService _notificationService;
  int _applicationCount = 0;
  int _petCount = 0;
  int _unreadNotifications = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adoptionService = AdoptionService();
    _notificationService = NotificationService();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (user.role == UserRole.adopter) {
      final applications = await _adoptionService.getUserApplications(user.id);
      setState(() {
        _applicationCount = applications.length;
      });
    } else if (user.role == UserRole.shelter) {
      final pets = await _petService.getPetsByShelter(user.id);
      setState(() {
        _petCount = pets.length;
      });
    }

    final unreadCount = await _notificationService.getUnreadCount(user.id);
    setState(() {
      _unreadNotifications = unreadCount;
      _isLoading = false;
    });
  }

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

          return RefreshIndicator(
            onRefresh: _loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                  
                  // Statistics Cards
                  if (!_isLoading) _buildStatisticsCards(context, user),
                  
                  const SizedBox(height: 24),
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
                  
                  // Action Cards
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                )
                                .then((_) => _loadStats());
                          },
                        ),
                        if (user.role == UserRole.adopter)
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('My Applications'),
                            subtitle: _isLoading
                                ? null
                                : Text('$_applicationCount applications'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).pushNamed(AppConstants.myApplicationsRoute);
                            },
                          ),
                        if (user.role == UserRole.shelter)
                          ListTile(
                            leading: const Icon(Icons.dashboard),
                            title: const Text('Shelter Dashboard'),
                            subtitle: _isLoading
                                ? null
                                : Text('$_petCount pets'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).pushNamed(AppConstants.shelterDashboardRoute);
                            },
                          ),
                        ListTile(
                          leading: Stack(
                            children: [
                              const Icon(Icons.notifications),
                              if (_unreadNotifications > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$_unreadNotifications',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: const Text('Notifications'),
                          subtitle: _unreadNotifications > 0
                              ? Text('$_unreadNotifications unread')
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).pushNamed(AppConstants.notificationsRoute);
                          },
                        ),
                        if (user.role == UserRole.admin)
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Admin Dashboard'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).pushNamed(AppConstants.adminDashboardRoute);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppConstants.loginRoute,
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, User user) {
    if (user.role == UserRole.adopter) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.description,
                      label: 'Applications',
                      value: '$_applicationCount',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.pending,
                      label: 'Pending',
                      value: '0',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (user.role == UserRole.shelter) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.pets,
                      label: 'Total Pets',
                      value: '$_petCount',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.check_circle,
                      label: 'Available',
                      value: '0',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

