import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../utils/constants.dart';
import 'adoption_form_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PetService _petService = PetService();
  Pet? _pet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    final pet = await _petService.getPetById(widget.petId);
    setState(() {
      _pet = pet;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pet == null
              ? const Center(child: Text('Pet not found'))
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pet!.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.pets,
                                  label: _pet!.species.name.toUpperCase(),
                                ),
                                const SizedBox(width: 8),
                                _InfoChip(
                                  icon: Icons.straighten,
                                  label: _pet!.size.name.toUpperCase(),
                                ),
                                const SizedBox(width: 8),
                                _InfoChip(
                                  icon: Icons.location_on,
                                  label: _pet!.city,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildSectionTitle('Age'),
                            Text('${_pet!.age} months old'),
                            const SizedBox(height: 16),
                            _buildSectionTitle('Description'),
                            Text(_pet!.description),
                            if (_pet!.healthStatus != null) ...[
                              const SizedBox(height: 16),
                              _buildSectionTitle('Health Status'),
                              Text(_pet!.healthStatus!),
                            ],
                            if (_pet!.shelterName != null) ...[
                              const SizedBox(height: 16),
                              _buildSectionTitle('Shelter'),
                              Text(_pet!.shelterName!),
                            ],
                            const SizedBox(height: 100), // Space for button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _pet != null && _pet!.status == PetStatus.available
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdoptionFormScreen(petId: _pet!.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Apply for Adoption'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _pet!.imageUrls.isNotEmpty
            ? Image.network(
                _pet!.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.pets,
          size: 100,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

