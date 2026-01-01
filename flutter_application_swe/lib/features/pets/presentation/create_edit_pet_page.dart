import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pet_provider.dart';
import '../../../core/services/pet_service.dart';

class CreateEditPetPage extends ConsumerStatefulWidget {
  final String? petId;

  const CreateEditPetPage({super.key, this.petId});

  @override
  ConsumerState<CreateEditPetPage> createState() => _CreateEditPetPageState();
}

class _CreateEditPetPageState extends ConsumerState<CreateEditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _healthStatusController = TextEditingController();

  PetSpecies _selectedSpecies = PetSpecies.dog;
  PetSize _selectedSize = PetSize.medium;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.petId != null) {
      _loadPet();
    }
  }

  Future<void> _loadPet() async {
    final petAsync = ref.read(petDetailProvider(widget.petId!));
    petAsync.whenData((pet) {
      if (pet != null) {
        setState(() {
          _nameController.text = pet.name;
          _ageController.text = pet.age.toString();
          _descriptionController.text = pet.description;
          _cityController.text = pet.city;
          _healthStatusController.text = pet.healthStatus ?? '';
          _selectedSpecies = pet.species;
          _selectedSize = pet.size;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _healthStatusController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final petService = ref.read(petServiceProvider);
      final age = int.parse(_ageController.text);

      if (widget.petId != null) {
        // Edit existing pet
        final existingPetAsync = ref.read(petDetailProvider(widget.petId!));
        existingPetAsync.whenData((pet) async {
          if (pet != null) {
            await petService.updatePet(
              pet.copyWith(
                name: _nameController.text.trim(),
                age: age,
                species: _selectedSpecies,
                size: _selectedSize,
                description: _descriptionController.text.trim(),
                city: _cityController.text.trim(),
                healthStatus: _healthStatusController.text.trim().isEmpty
                    ? null
                    : _healthStatusController.text.trim(),
              ),
            );
          }
        });
      } else {
        // Create new pet
        await petService.createPet(
          name: _nameController.text.trim(),
          age: age,
          species: _selectedSpecies,
          size: _selectedSize,
          description: _descriptionController.text.trim(),
          city: _cityController.text.trim(),
          shelterId: user.id,
          shelterName: user.name,
          healthStatus: _healthStatusController.text.trim().isEmpty
              ? null
              : _healthStatusController.text.trim(),
        );
      }

      if (mounted) {
        ref.invalidate(petsProvider);
        ref.invalidate(shelterPetsProvider(user.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.petId != null ? 'Pet updated successfully' : 'Pet created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petId != null ? 'Edit Pet' : 'Add New Pet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 0) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<PetSpecies>(
                      value: _selectedSpecies,
                      decoration: const InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
                      items: PetSpecies.values.map((species) {
                        return DropdownMenuItem(
                          value: species,
                          child: Text(species.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSpecies = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PetSize>(
                value: _selectedSize,
                decoration: const InputDecoration(
                  labelText: 'Size',
                  border: OutlineInputBorder(),
                ),
                items: PetSize.values.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSize = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _healthStatusController,
                decoration: const InputDecoration(
                  labelText: 'Health Status (Optional)',
                  prefixIcon: Icon(Icons.health_and_safety),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Vaccinated, Healthy, Neutered',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.petId != null ? 'Update Pet' : 'Create Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

