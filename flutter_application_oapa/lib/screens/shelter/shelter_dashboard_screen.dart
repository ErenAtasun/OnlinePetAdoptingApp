import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../models/adoption_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/pet_service.dart';
import '../../services/adoption_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import 'create_pet_screen.dart';
import 'application_review_screen.dart';

class ShelterDashboardScreen extends StatefulWidget {
  const ShelterDashboardScreen({super.key});

  @override
  State<ShelterDashboardScreen> createState() => _ShelterDashboardScreenState();
}

class _ShelterDashboardScreenState extends State<ShelterDashboardScreen> {
  final PetService _petService = PetService();
  late AdoptionService _adoptionService;
  List<Pet> _pets = [];
  int _pendingApplicationsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adoptionService = AdoptionService(
      _petService,
      NotificationService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final pets = await _petService.getPetsByShelter(user.id);
    final applications = await _adoptionService.getShelterApplications(user.id);
    final pendingCount = applications.where((a) => a.status == AdoptionStatus.pending).length;

    setState(() {
      _pets = pets;
      _pendingApplicationsCount = pendingCount;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelter Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Pets',
                            value: _pets.length.toString(),
                            icon: Icons.pets,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Available',
                            value: _pets
                                .where((p) => p.status == PetStatus.available)
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Pending Apps',
                            value: _pendingApplicationsCount.toString(),
                            icon: Icons.pending,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Adopted',
                            value: _pets
                                .where((p) => p.status == PetStatus.adopted)
                                .length
                                .toString(),
                            icon: Icons.favorite,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const CreatePetScreen(),
                              ),
                            )
                            .then((_) => _loadData());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Pet'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Pets',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppConstants.applicationReviewRoute);
                          },
                          child: const Text('View Applications'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _pets.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No pets yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first pet to get started',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pets.length,
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.pets),
                                  ),
                                  title: Text(
                                    pet.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${pet.species.name.toUpperCase()} • ${pet.size.name.toUpperCase()}'),
                                      const SizedBox(height: 4),
                                      Text('Status: ${pet.status.name.toUpperCase()}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) => CreatePetScreen(pet: pet),
                                                ),
                                              )
                                              .then((_) => _loadData());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CreatePetScreen(),
                ),
              )
              .then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

