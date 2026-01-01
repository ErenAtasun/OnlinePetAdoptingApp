import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/adoption_request.dart';
import '../../../core/models/pet.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pet_provider.dart';
import '../../../core/providers/adoption_provider.dart';

class ShelterDashboardPage extends ConsumerWidget {
  const ShelterDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: Text('Please login')),
      );
    }

    final petsAsync = ref.watch(shelterPetsProvider(user.id));
    final applicationsAsync = ref.watch(shelterApplicationsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/shelter/pets/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shelterPetsProvider(user.id));
          ref.invalidate(shelterApplicationsProvider(user.id));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              applicationsAsync.when(
                data: (applications) {
                  final pendingCount =
                      applications.where((a) => a.status == AdoptionRequestStatus.pending).length;
                  
                  return Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pending Applications',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '$pendingCount applications',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (pendingCount > 0)
                            TextButton(
                              onPressed: () => context.push('/shelter/applications'),
                              child: const Text('Review'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Pet Listings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/shelter/pets/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              petsAsync.when(
                data: (pets) {
                  if (pets.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pets listed yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/shelter/pets/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Pet'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.pets),
                          ),
                          title: Text(pet.name),
                          subtitle: Text('${pet.species.name} • ${pet.age} ${pet.age == 1 ? 'year' : 'years'}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(pet.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pet.status.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => context.push('/shelter/pets/${pet.id}/edit'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PetStatus status) {
    switch (status) {
      case PetStatus.available:
        return Colors.green;
      case PetStatus.pending:
        return Colors.orange;
      case PetStatus.adopted:
        return Colors.grey;
    }
  }
}

