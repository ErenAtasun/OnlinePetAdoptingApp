import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final ImagePicker _imagePicker = ImagePicker();

  PetSpecies _selectedSpecies = PetSpecies.dog;
  PetSize _selectedSize = PetSize.medium;
  PetStatus _selectedStatus = PetStatus.available;
  bool _isLoading = false;
  List<XFile> _selectedImages = [];

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
        imageUrls: widget.pet != null && _selectedImages.isEmpty
            ? widget.pet!.imageUrls
            : _selectedImages.map((img) => img.path).toList(),
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

  Future<void> _selectImages() async {
    try {
      if (_selectedImages.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can add up to 5 photos'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          final remainingSlots = 5 - _selectedImages.length;
          if (images.length > remainingSlots) {
            _selectedImages.addAll(images.take(remainingSlots));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only first $remainingSlots photos were added'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            _selectedImages.addAll(images);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
              // Pet Images Section
              Text(
                'Pet Photos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add photos of the pet (up to 5)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: _selectImages,
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
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

