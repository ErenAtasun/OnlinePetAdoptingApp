import '../models/adoption_request.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../services/notification_service.dart';

class AdoptionService {
  // Singleton instance
  static final AdoptionService _instance = AdoptionService._internal();
  factory AdoptionService() => _instance;
  AdoptionService._internal() {
    _petService = PetService();
    _notificationService = NotificationService();
  }

  final List<AdoptionRequest> _requests = [];
  int _idCounter = 0;
  late final PetService _petService;
  late final NotificationService _notificationService;

  List<AdoptionRequest> get requests => List.unmodifiable(_requests);

  void reset() {
    _requests.clear();
    _idCounter = 0;
  }

  Future<AdoptionRequest> submitApplication({
    required String petId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhoneNumber,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      throw const FormatException('Application message is required');
    }

    final pet = await _petService.getPetById(petId);
    if (pet == null) {
      throw StateError('Pet not found');
    }

    final hasExistingRequest =
        _requests.any((r) => r.petId == petId && r.userId == userId);
    if (hasExistingRequest) {
      throw StateError('User has already applied for this pet');
    }

    if (pet.status == PetStatus.adopted) {
      throw StateError('Pet is not available for adoption');
    }

    final request = AdoptionRequest(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
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

    // Update pet status if still available
    if (pet.status == PetStatus.available) {
      await _petService.updatePet(pet.copyWith(status: PetStatus.pending));
    }

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

  Future<AdoptionRequest> approveApplication({
    required String requestId,
    required String petId,
    required String shelterId,
  }) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    if (request.petId != petId) {
      throw StateError('Application does not belong to this pet');
    }
    if (request.status != AdoptionStatus.pending) {
      throw StateError('Only pending applications can be approved');
    }

    final pet = await _petService.getPetById(petId);
    if (pet == null) {
      throw StateError('Pet not found');
    }
    if (pet.shelterId != null && pet.shelterId != shelterId) {
      throw StateError('Unauthorized shelter action');
    }

    final updatedRequest = request.copyWith(
      status: AdoptionStatus.approved,
      reviewedAt: DateTime.now(),
    );

    final index = _requests.indexWhere((r) => r.id == requestId);
    _requests[index] = updatedRequest;

    await _petService.updatePet(pet.copyWith(status: PetStatus.adopted));

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

  Future<AdoptionRequest> rejectApplication({
    required String requestId,
    required String shelterId,
    String? reason,
  }) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    if (request.status != AdoptionStatus.pending) {
      throw StateError('Only pending applications can be rejected');
    }

    final pet = await _petService.getPetById(request.petId);
    if (pet == null) {
      throw StateError('Pet not found');
    }
    if (pet.shelterId != null && pet.shelterId != shelterId) {
      throw StateError('Unauthorized shelter action');
    }

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
      await _petService.updatePet(pet.copyWith(status: PetStatus.available));
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

