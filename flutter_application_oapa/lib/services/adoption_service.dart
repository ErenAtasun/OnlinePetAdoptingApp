import '../models/adoption_request.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../services/notification_service.dart';

class AdoptionService {
  final List<AdoptionRequest> _requests = [];
  final PetService _petService;
  final NotificationService _notificationService;

  AdoptionService(this._petService, this._notificationService);

  Future<AdoptionRequest> submitApplication({
    required String petId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhoneNumber,
    required String message,
  }) async {
    final pet = await _petService.getPetById(petId);
    if (pet == null) {
      throw Exception('Pet not found');
    }

    final request = AdoptionRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      petName: pet.name,
      petImageUrl: pet.imageUrls.isNotEmpty ? pet.imageUrls.first : null,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhoneNumber: userPhoneNumber,
      message: message,
      status: AdoptionStatus.pending,
      submittedAt: DateTime.now(),
    );

    _requests.add(request);

    // Update pet status
    await _petService.updatePet(pet.copyWith(status: PetStatus.pending));

    // Notify shelter (in real app, this would be async)
    await _notificationService.createNotification(
      userId: pet.shelterId ?? '',
      message: 'New adoption application for ${pet.name}',
      type: 'application_review',
    );

    return request;
  }

  Future<List<AdoptionRequest>> getUserApplications(String userId) async {
    return _requests.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<List<AdoptionRequest>> getPetApplications(String petId) async {
    return _requests.where((r) => r.petId == petId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<List<AdoptionRequest>> getShelterApplications(String shelterId) async {
    // Get all pets for this shelter, then get their applications
    final pets = await _petService.getPetsByShelter(shelterId);
    final petIds = pets.map((p) => p.id).toSet();
    return _requests
        .where((r) => petIds.contains(r.petId))
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<AdoptionRequest> approveApplication(String requestId, String petId) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    final updatedRequest = request.copyWith(
      status: AdoptionStatus.approved,
      reviewedAt: DateTime.now(),
    );

    final index = _requests.indexWhere((r) => r.id == requestId);
    _requests[index] = updatedRequest;

    // Update pet status
    final pet = await _petService.getPetById(petId);
    if (pet != null) {
      await _petService.updatePet(pet.copyWith(status: PetStatus.adopted));
    }

    // Reject other pending applications for the same pet
    for (var req in _requests) {
      if (req.petId == petId &&
          req.id != requestId &&
          req.status == AdoptionStatus.pending) {
        final rejectedRequest = req.copyWith(
          status: AdoptionStatus.rejected,
          reviewedAt: DateTime.now(),
          rejectionReason: 'Pet has been adopted by another applicant',
        );
        final reqIndex = _requests.indexWhere((r) => r.id == req.id);
        _requests[reqIndex] = rejectedRequest;

        await _notificationService.createNotification(
          userId: req.userId,
          message: 'Your application for ${req.petName} was not selected',
          type: 'adoption_status',
        );
      }
    }

    // Notify user
    await _notificationService.createNotification(
      userId: request.userId,
      message: 'Congratulations! Your application for ${request.petName} has been approved!',
      type: 'adoption_status',
    );

    return updatedRequest;
  }

  Future<AdoptionRequest> rejectApplication(
    String requestId,
    String? reason,
  ) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    final updatedRequest = request.copyWith(
      status: AdoptionStatus.rejected,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );

    final index = _requests.indexWhere((r) => r.id == requestId);
    _requests[index] = updatedRequest;

    // Update pet status back to available if no other pending applications
    final petApplications = await getPetApplications(request.petId);
    final hasPending = petApplications.any((r) => r.status == AdoptionStatus.pending);
    if (!hasPending) {
      final pet = await _petService.getPetById(request.petId);
      if (pet != null) {
        await _petService.updatePet(pet.copyWith(status: PetStatus.available));
      }
    }

    // Notify user
    await _notificationService.createNotification(
      userId: request.userId,
      message: 'Your application for ${request.petName} was not approved',
      type: 'adoption_status',
    );

    return updatedRequest;
  }
}

