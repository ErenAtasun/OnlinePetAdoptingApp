import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/adoption_request.dart';
import '../providers/auth_provider.dart';
import '../services/adoption_service.dart';
import '../services/pet_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
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

    final applications = await _adoptionService.getUserApplications(user.id);
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
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
        title: const Text('My Applications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apply for a pet to see your applications here',
                        style: TextStyle(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: application.petImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      application.petImageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.pets);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.pets),
                          ),
                          title: Text(
                            application.petName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Applied: ${_formatDate(application.submittedAt)}',
                              ),
                              if (application.reviewedAt != null)
                                Text(
                                  'Reviewed: ${_formatDate(application.reviewedAt!)}',
                                ),
                              if (application.rejectionReason != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Reason: ${application.rejectionReason}',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                          isThreeLine: true,
                          onTap: () {
                            _showApplicationDetails(application);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApplicationDetails(AdoptionRequest application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application for ${application.petName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: ${application.status.name.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(application.status),
                ),
              ),
              const SizedBox(height: 16),
              Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

