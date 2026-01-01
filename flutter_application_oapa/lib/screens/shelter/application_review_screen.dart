import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/adoption_request.dart';
import '../../models/pet.dart';
import '../../providers/auth_provider.dart';
import '../../services/pet_service.dart';
import '../../services/adoption_service.dart';
import '../../services/notification_service.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key});

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  final PetService _petService = PetService();
  late AdoptionService _adoptionService;
  List<AdoptionRequest> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adoptionService = AdoptionService();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final applications = await _adoptionService.getShelterApplications(user.id);
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  Future<void> _approveApplication(AdoptionRequest application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Text('Are you sure you want to approve the application for ${application.petName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _adoptionService.approveApplication(application.id, application.petId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadApplications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectApplication(AdoptionRequest application) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this application?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
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
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _adoptionService.rejectApplication(
        application.id,
        reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadApplications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(AdoptionStatus status) {
    switch (status) {
      case AdoptionStatus.pending:
        return Colors.orange;
      case AdoptionStatus.approved:
        return Colors.green;
      case AdoptionStatus.rejected:
        return Colors.red;
      case AdoptionStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Applications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadApplications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _applications.length,
                    itemBuilder: (context, index) {
                      final application = _applications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person),
                          ),
                          title: Text(
                            application.petName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Applicant: ${application.userName}'),
                              Text('Applied: ${_formatDate(application.submittedAt)}'),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(application.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              application.status.name.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(application.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildInfoRow('Email', application.userEmail),
                                  if (application.userPhoneNumber != null)
                                    _buildInfoRow('Phone', application.userPhoneNumber!),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Message:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(application.message),
                                  if (application.rejectionReason != null) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Rejection Reason:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      application.rejectionReason!,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ],
                                  if (application.status == AdoptionStatus.pending) ...[
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _rejectApplication(application),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _approveApplication(application),
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

