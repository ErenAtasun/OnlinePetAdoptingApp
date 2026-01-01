import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/pet_service.dart';
import '../services/adoption_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'pet_detail_screen.dart';
import 'auth/login_screen.dart';
import 'my_applications_screen.dart';
import 'shelter/shelter_dashboard_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PetService _petService = PetService();
  final TextEditingController _searchController = TextEditingController();
  List<Pet> _pets = [];
  List<Pet> _filteredPets = [];
  bool _isLoading = true;
  
  PetSpecies? _selectedSpecies;
  PetSize? _selectedSize;
  String _selectedCity = '';

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    final pets = await _petService.getPets();
    
    setState(() {
      _pets = pets;
      _filteredPets = pets;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPets = _pets.where((pet) {
        if (_selectedSpecies != null && pet.species != _selectedSpecies) {
          return false;
        }
        if (_selectedSize != null && pet.size != _selectedSize) {
          return false;
        }
        if (_selectedCity.isNotEmpty &&
            !pet.city.toLowerCase().contains(_selectedCity.toLowerCase())) {
          return false;
        }
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty &&
            !pet.name.toLowerCase().contains(query) &&
            !pet.description.toLowerCase().contains(query)) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          if (currentUser != null) ...[
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  // Add badge for unread notifications if needed
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.notificationsRoute);
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.of(context).pushNamed(AppConstants.profileRoute);
                    break;
                  case 'applications':
                    if (currentUser?.role == UserRole.adopter ||
                        currentUser?.role == UserRole.visitor) {
                      Navigator.of(context).pushNamed(AppConstants.myApplicationsRoute);
                    }
                    break;
                  case 'dashboard':
                    if (currentUser?.role == UserRole.shelter) {
                      Navigator.of(context).pushNamed(AppConstants.shelterDashboardRoute);
                    }
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<String>>[];
                
                if (currentUser?.role == UserRole.shelter) {
                  items.add(const PopupMenuItem(
                    value: 'dashboard',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard),
                        SizedBox(width: 8),
                        Text('Shelter Dashboard'),
                      ],
                    ),
                  ));
                }
                
                if (currentUser?.role == UserRole.adopter) {
                  items.add(const PopupMenuItem(
                    value: 'applications',
                    child: Row(
                      children: [
                        Icon(Icons.description),
                        SizedBox(width: 8),
                        Text('My Applications'),
                      ],
                    ),
                  ));
                }

                items.addAll([
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ]);

                return items;
              },
            ),
          ] else
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.loginRoute);
              },
              child: const Text('Login'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pets...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Species'),
                  selected: _selectedSpecies == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecies = null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...PetSpecies.values.map((species) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(species.name.toUpperCase()),
                      selected: _selectedSpecies == species,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSpecies = selected ? species : null;
                          _applyFilters();
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('All Sizes'),
                  selected: _selectedSize == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSize = null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...PetSize.values.map((size) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(size.name.toUpperCase()),
                      selected: _selectedSize == size,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSize = selected ? size : null;
                          _applyFilters();
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pet list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pets found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = _filteredPets[index];
                          return _PetCard(
                            pet: pet,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PetDetailScreen(petId: pet.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
    }
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const _PetCard({
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: pet.imageUrls.isNotEmpty
                    ? Image.network(
                        pet.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderIcon();
                        },
                      )
                    : _buildPlaceholderIcon(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        pet.species.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        pet.city,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.age} months old',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.pets,
        size: 64,
        color: Colors.grey[400],
      ),
    );
  }
}

