import '../models/pet.dart';

class PetService {
  // Singleton instance
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  // In-memory storage (in real app, this would be API calls)
  final List<Pet> _pets = [];
  bool _initialized = false;

  void initializeDemoData() {
    if (_initialized) return; // Already initialized
    _initialized = true;
    _pets.addAll([
      Pet(
        id: '1',
        name: 'Buddy',
        age: 24, // 2 years
        species: PetSpecies.dog,
        size: PetSize.medium,
        description:
            'Buddy is a friendly and energetic dog who loves to play. He is well-trained and gets along with children. Perfect for active families!',
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
            'Luna is a gentle and calm cat. She prefers a quiet home and loves to cuddle. Great companion for seniors or quiet households.',
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
            'Max is a loyal and protective companion. He requires an experienced owner and loves outdoor activities.',
        status: PetStatus.available,
        city: 'Izmir',
        imageUrls: [],
        healthStatus: 'Vaccinated, healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Pet(
        id: '4',
        name: 'Charlie',
        age: 18, // 1.5 years
        species: PetSpecies.dog,
        size: PetSize.small,
        description:
            'Charlie is a playful and intelligent small dog. Perfect for apartment living. Loves toys and treats!',
        status: PetStatus.available,
        city: 'Istanbul',
        imageUrls: [],
        healthStatus: 'Vaccinated, microchipped',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Pet(
        id: '5',
        name: 'Mia',
        age: 8, // 8 months
        species: PetSpecies.cat,
        size: PetSize.small,
        description:
            'Mia is a young, playful kitten. She is very active and loves to explore. Gets along with other cats.',
        status: PetStatus.available,
        city: 'Bursa',
        imageUrls: [],
        healthStatus: 'Vaccinated, dewormed',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Pet(
        id: '6',
        name: 'Rocky',
        age: 48, // 4 years
        species: PetSpecies.dog,
        size: PetSize.large,
        description:
            'Rocky is a strong and friendly large breed dog. Great with kids and other dogs. Needs daily exercise.',
        status: PetStatus.available,
        city: 'Ankara',
        imageUrls: [],
        healthStatus: 'Vaccinated, neutered, healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Pet(
        id: '7',
        name: 'Bella',
        age: 30, // 2.5 years
        species: PetSpecies.cat,
        size: PetSize.medium,
        description:
            'Bella is a beautiful and affectionate cat. She loves attention and enjoys being petted. Indoor cat preferred.',
        status: PetStatus.available,
        city: 'Antalya',
        imageUrls: [],
        healthStatus: 'Vaccinated, spayed, healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Pet(
        id: '8',
        name: 'Coco',
        age: 6, // 6 months
        species: PetSpecies.bird,
        size: PetSize.small,
        description:
            'Coco is a friendly parrot who loves to interact with people. Can learn words and enjoys music.',
        status: PetStatus.available,
        city: 'Istanbul',
        imageUrls: [],
        healthStatus: 'Healthy, vet checked',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Pet(
        id: '9',
        name: 'Daisy',
        age: 15, // 1.25 years
        species: PetSpecies.rabbit,
        size: PetSize.small,
        description:
            'Daisy is a cute and gentle rabbit. She is litter trained and enjoys fresh vegetables. Great for families with children.',
        status: PetStatus.available,
        city: 'Izmir',
        imageUrls: [],
        healthStatus: 'Healthy, vaccinated',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Pet(
        id: '10',
        name: 'Simba',
        age: 42, // 3.5 years
        species: PetSpecies.cat,
        size: PetSize.medium,
        description:
            'Simba is a majestic and independent cat. He enjoys his space but also likes occasional cuddles. Perfect for a calm home.',
        status: PetStatus.available,
        city: 'Ankara',
        imageUrls: [],
        healthStatus: 'Vaccinated, neutered',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
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

