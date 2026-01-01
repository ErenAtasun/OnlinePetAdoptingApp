import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/adoption_request.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/adoption_provider.dart';
import '../../../core/providers/pet_provider.dart';

class ApplicationsReviewPage extends ConsumerWidget {
  const ApplicationsReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applications')),
        body: const Center(child: Text('Please login')),
      );
    }

    final applicationsAsync = ref.watch(shelterApplicationsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Applications'),
      ),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shelterApplicationsProvider(user.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return _ApplicationReviewCard(
                  application: application,
                  shelterId: user.id,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ApplicationReviewCard extends ConsumerWidget {
  final AdoptionRequest application;
  final String shelterId;

  const _ApplicationReviewCard({
    required this.application,
    required this.shelterId,
  });

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    AdoptionRequestStatus status,
  ) async {
    try {
      final adoptionService = ref.read(adoptionServiceProvider);
      await adoptionService.updateRequestStatus(
        requestId: application.id,
        status: status,
        shelterId: shelterId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application ${status.name}'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(shelterApplicationsProvider(shelterId));
        ref.invalidate(petsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petDetailProvider(application.petId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: petAsync.when(
                    data: (pet) => Text(
                      pet?.name ?? 'Unknown Pet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (error, stack) => const Text('Unknown Pet'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Applicant', application.userName),
            _buildInfoRow('Email', application.userEmail),
            if (application.userPhone != null)
              _buildInfoRow('Phone', application.userPhone!),
            _buildInfoRow(
              'Applied',
              DateFormat('MMM dd, yyyy').format(application.createdAt),
            ),
            if (application.message != null && application.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Message:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(application.message!),
            ],
            if (application.status == AdoptionRequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(
                        context,
                        ref,
                        AdoptionRequestStatus.rejected,
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(
                        context,
                        ref,
                        AdoptionRequestStatus.approved,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AdoptionRequestStatus status) {
    switch (status) {
      case AdoptionRequestStatus.pending:
        return Colors.orange;
      case AdoptionRequestStatus.approved:
        return Colors.green;
      case AdoptionRequestStatus.rejected:
        return Colors.red;
    }
  }
}

