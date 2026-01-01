import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/adoption_request.dart';
import '../models/pet.dart';
import 'pet_service.dart';
import 'notification_service.dart';

class AdoptionService {
  static const String _requestsKey = 'adoption_requests';
  final _uuid = const Uuid();
  final _petService = PetService();
  final _notificationService = NotificationService();

  Future<AdoptionRequest> submitApplication({
    required String petId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? message,
  }) async {
    // Check if pet exists and is available
    final pet = await _petService.getPetById(petId);
    if (pet == null) {
      throw Exception('Pet not found');
    }
    if (pet.status != PetStatus.available) {
      throw Exception('Pet is not available for adoption');
    }

    // Check if user already applied
    final existingRequests = await getRequestsByUser(userId);
    if (existingRequests.any((r) => r.petId == petId && r.status == AdoptionRequestStatus.pending)) {
      throw Exception('You have already applied for this pet');
    }

    final request = AdoptionRequest(
      id: _uuid.v4(),
      petId: petId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      status: AdoptionRequestStatus.pending,
      message: message,
      createdAt: DateTime.now(),
    );

    final requests = await getAllRequests();
    requests.add(request);
    await _saveRequests(requests);

    // Update pet status to pending
    await _petService.updatePet(pet.copyWith(status: PetStatus.pending));

    // Notify shelter
    await _notificationService.createNotification(
      userId: pet.shelterId,
      message: 'New adoption application for ${pet.name} from $userName',
      type: 'application_received',
    );

    // Notify user
    await _notificationService.createNotification(
      userId: userId,
      message: 'Your adoption application for ${pet.name} has been submitted',
      type: 'application_submitted',
    );

    return request;
  }

  Future<List<AdoptionRequest>> getAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_requestsKey);
    
    if (requestsJson == null) {
      return [];
    }

    final List<dynamic> requestsList = jsonDecode(requestsJson) as List;
    return requestsList.map((e) => AdoptionRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AdoptionRequest>> getRequestsByUser(String userId) async {
    final requests = await getAllRequests();
    return requests.where((r) => r.userId == userId).toList();
  }

  Future<List<AdoptionRequest>> getRequestsByPet(String petId) async {
    final requests = await getAllRequests();
    return requests.where((r) => r.petId == petId).toList();
  }

  Future<List<AdoptionRequest>> getRequestsByShelter(String shelterId) async {
    final requests = await getAllRequests();
    final shelterPets = await _petService.getPetsByShelter(shelterId);
    final petIds = shelterPets.map((p) => p.id).toSet();
    
    return requests.where((r) => petIds.contains(r.petId)).toList();
  }

  Future<AdoptionRequest> updateRequestStatus({
    required String requestId,
    required AdoptionRequestStatus status,
    required String shelterId,
  }) async {
    final requests = await getAllRequests();
    final index = requests.indexWhere((r) => r.id == requestId);
    
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = requests[index];
    final pet = await _petService.getPetById(request.petId);
    
    if (pet == null || pet.shelterId != shelterId) {
      throw Exception('Unauthorized');
    }

    requests[index] = request.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    await _saveRequests(requests);

    // Update pet status
    if (status == AdoptionRequestStatus.approved) {
      await _petService.updatePet(pet.copyWith(status: PetStatus.adopted));
      
      // Reject other pending requests for the same pet
      for (var otherRequest in requests) {
        if (otherRequest.petId == request.petId &&
            otherRequest.id != requestId &&
            otherRequest.status == AdoptionRequestStatus.pending) {
          final otherIndex = requests.indexWhere((r) => r.id == otherRequest.id);
          requests[otherIndex] = otherRequest.copyWith(
            status: AdoptionRequestStatus.rejected,
            updatedAt: DateTime.now(),
          );
          
          // Notify rejected users
          await _notificationService.createNotification(
            userId: otherRequest.userId,
            message: 'Your adoption application for ${pet.name} has been rejected',
            type: 'adoption_status',
          );
        }
      }
      
      await _saveRequests(requests);
    } else if (status == AdoptionRequestStatus.rejected) {
      // Check if there are other pending requests
      final pendingRequests = requests.where(
        (r) => r.petId == request.petId && r.status == AdoptionRequestStatus.pending,
      ).toList();
      
      if (pendingRequests.isEmpty) {
        await _petService.updatePet(pet.copyWith(status: PetStatus.available));
      }
    }

    // Notify user
    final statusText = status == AdoptionRequestStatus.approved ? 'approved' : 'rejected';
    await _notificationService.createNotification(
      userId: request.userId,
      message: 'Your adoption application for ${pet.name} has been $statusText',
      type: 'adoption_status',
    );

    return requests[index];
  }

  Future<void> _saveRequests(List<AdoptionRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _requestsKey,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }
}

