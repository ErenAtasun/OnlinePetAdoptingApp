import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adoption_request.dart';
import '../services/adoption_service.dart';

final adoptionServiceProvider = Provider<AdoptionService>((ref) => AdoptionService());

final userApplicationsProvider = FutureProvider.family<List<AdoptionRequest>, String>((ref, userId) async {
  final service = ref.watch(adoptionServiceProvider);
  return service.getRequestsByUser(userId);
});

final petApplicationsProvider = FutureProvider.family<List<AdoptionRequest>, String>((ref, petId) async {
  final service = ref.watch(adoptionServiceProvider);
  return service.getRequestsByPet(petId);
});

final shelterApplicationsProvider = FutureProvider.family<List<AdoptionRequest>, String>((ref, shelterId) async {
  final service = ref.watch(adoptionServiceProvider);
  return service.getRequestsByShelter(shelterId);
});

