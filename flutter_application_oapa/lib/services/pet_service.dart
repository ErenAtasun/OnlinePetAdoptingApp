import '../models/pet.dart';

class PetService {
  // In-memory storage (in real app, this would be API calls)
  final List<Pet> _pets = [];

  void initializeDemoData() {
    _pets.addAll([
      Pet(
        id: '1',
        name: 'Buddy',
        age: 24, // 2 years
        species: PetSpecies.dog,
        size: PetSize.medium,
        description:
            'Buddy is a friendly and energetic dog who loves to play. He is well-trained and gets along with children.',
        status: PetStatus.available,
        city: 'Istanbul',
        imageUrls: [],
        healthStatus: 'Vaccinated and healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Pet(
        id: '2',
        name: 'Luna',
        age: 12, // 1 year
        species: PetSpecies.cat,
        size: PetSize.small,
        description:
            'Luna is a gentle and calm cat. She prefers a quiet home and loves to cuddle.',
        status: PetStatus.available,
        city: 'Ankara',
        imageUrls: [],
        healthStatus: 'Vaccinated, spayed',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Pet(
        id: '3',
        name: 'Max',
        age: 36, // 3 years
        species: PetSpecies.dog,
        size: PetSize.large,
        description:
            'Max is a loyal and protective companion. He requires an experienced owner.',
        status: PetStatus.available,
        city: 'Izmir',
        imageUrls: [],
        healthStatus: 'Vaccinated, healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);
  }

  Future<List<Pet>> getPets({
    PetSpecies? species,
    PetSize? size,
    String? city,
    int? minAge,
    int? maxAge,
    String? searchQuery,
  }) async {
    var filtered = List<Pet>.from(_pets);

    if (species != null) {
      filtered = filtered.where((p) => p.species == species).toList();
    }

    if (size != null) {
      filtered = filtered.where((p) => p.size == size).toList();
    }

    if (city != null && city.isNotEmpty) {
      filtered =
          filtered.where((p) => p.city.toLowerCase().contains(city.toLowerCase())).toList();
    }

    if (minAge != null) {
      filtered = filtered.where((p) => p.age >= minAge).toList();
    }

    if (maxAge != null) {
      filtered = filtered.where((p) => p.age <= maxAge).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    // Only return available pets
    return filtered.where((p) => p.status == PetStatus.available).toList();
  }

  Future<Pet?> getPetById(String id) async {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Pet>> getPetsByShelter(String shelterId) async {
    return _pets.where((p) => p.shelterId == shelterId).toList();
  }

  Future<Pet> createPet(Pet pet) async {
    _pets.add(pet);
    return pet;
  }

  Future<Pet> updatePet(Pet pet) async {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet.copyWith(updatedAt: DateTime.now());
      return _pets[index];
    }
    throw Exception('Pet not found');
  }

  Future<void> deletePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
  }
}

