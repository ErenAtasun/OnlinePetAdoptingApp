import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

final petServiceProvider = Provider<PetService>((ref) => PetService());

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final service = ref.watch(petServiceProvider);
  return service.getAllPets();
});

final petDetailProvider = FutureProvider.family<Pet?, String>((ref, petId) async {
  final service = ref.watch(petServiceProvider);
  return service.getPetById(petId);
});

final shelterPetsProvider = FutureProvider.family<List<Pet>, String>((ref, shelterId) async {
  final service = ref.watch(petServiceProvider);
  return service.getPetsByShelter(shelterId);
});

class PetSearchNotifier extends StateNotifier<List<Pet>> {
  final PetService _petService;

  PetSearchNotifier(this._petService) : super([]);

  Future<void> search({
    String? species,
    String? city,
    PetSize? size,
    int? minAge,
    int? maxAge,
  }) async {
    state = await _petService.searchPets(
      species: species,
      city: city,
      size: size,
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  void clear() {
    state = [];
  }
}

final petSearchProvider = StateNotifierProvider<PetSearchNotifier, List<Pet>>((ref) {
  return PetSearchNotifier(ref.watch(petServiceProvider));
});

