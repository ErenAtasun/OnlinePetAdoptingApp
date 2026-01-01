import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/auth_provider.dart';
import '../services/pet_service.dart';
import '../services/adoption_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'my_applications_screen.dart';

class AdoptionFormScreen extends StatefulWidget {
  final String petId;

  const AdoptionFormScreen({super.key, required this.petId});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final PetService _petService = PetService();
  late AdoptionService _adoptionService;
  Pet? _pet;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _adoptionService = AdoptionService(
      _petService,
      NotificationService(),
    );
    _loadPet();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadPet() async {
    final pet = await _petService.getPetById(widget.petId);
    setState(() {
      _pet = pet;
      _isLoading = false;
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit an application'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _adoptionService.submitApplication(
        petId: widget.petId,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userPhoneNumber: user.phoneNumber,
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(); // Go back
      Navigator.of(context).pushReplacementNamed(AppConstants.myApplicationsRoute);
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Application'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pet == null
              ? const Center(child: Text('Pet not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pet!.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_pet!.species.name.toUpperCase()} • ${_pet!.size.name.toUpperCase()} • ${_pet!.city}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tell us why you want to adopt ${_pet!.name}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share information about yourself, your home, and why you think you\'d be a good fit for this pet.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a message';
                            }
                            if (value.trim().length < 50) {
                              return 'Please provide at least 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Submit Application'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

