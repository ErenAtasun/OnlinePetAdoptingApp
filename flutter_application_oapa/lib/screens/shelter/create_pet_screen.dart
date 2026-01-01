import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../providers/auth_provider.dart';
import '../../services/pet_service.dart';

class CreatePetScreen extends StatefulWidget {
  final Pet? pet;

  const CreatePetScreen({super.key, this.pet});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final PetService _petService = PetService();

  PetSpecies _selectedSpecies = PetSpecies.dog;
  PetSize _selectedSize = PetSize.medium;
  PetStatus _selectedStatus = PetStatus.available;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _ageController.text = widget.pet!.age.toString();
      _descriptionController.text = widget.pet!.description;
      _cityController.text = widget.pet!.city;
      _healthStatusController.text = widget.pet!.healthStatus ?? '';
      _selectedSpecies = widget.pet!.species;
      _selectedSize = widget.pet!.size;
      _selectedStatus = widget.pet!.status;
    }
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

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        species: _selectedSpecies,
        size: _selectedSize,
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        city: _cityController.text.trim(),
        imageUrls: widget.pet?.imageUrls ?? [],
        healthStatus: _healthStatusController.text.trim().isEmpty
            ? null
            : _healthStatusController.text.trim(),
        shelterId: user.id,
        shelterName: user.name,
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.pet != null) {
        await _petService.updatePet(pet);
      } else {
        await _petService.createPet(pet);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.pet != null ? 'Pet updated successfully!' : 'Pet created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: Text(widget.pet != null ? 'Edit Pet' : 'Add New Pet'),
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age (in months)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter age';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PetSpecies>(
                value: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  prefixIcon: Icon(Icons.category),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<PetSize>(
                value: _selectedSize,
                decoration: const InputDecoration(
                  labelText: 'Size',
                  prefixIcon: Icon(Icons.straighten),
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
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
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PetStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                ),
                items: PetStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
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
                    : Text(widget.pet != null ? 'Update Pet' : 'Create Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

