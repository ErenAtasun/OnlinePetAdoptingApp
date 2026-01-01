import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pet.dart';

class PetService {
  static const String _petsKey = 'pets';
  final _uuid = const Uuid();

  Future<List<Pet>> getAllPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_petsKey);
    
    if (petsJson == null) {
      // Initialize with sample data
      return _initializeSamplePets();
    }

    final List<dynamic> petsList = jsonDecode(petsJson) as List;
    return petsList.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Pet>> searchPets({
    String? species,
    String? city,
    PetSize? size,
    int? minAge,
    int? maxAge,
  }) async {
    final allPets = await getAllPets();
    
    return allPets.where((pet) {
      if (species != null && pet.species.name != species) return false;
      if (city != null && !pet.city.toLowerCase().contains(city.toLowerCase())) return false;
      if (size != null && pet.size != size) return false;
      if (minAge != null && pet.age < minAge) return false;
      if (maxAge != null && pet.age > maxAge) return false;
      return true;
    }).toList();
  }

  Future<Pet?> getPetById(String id) async {
    final pets = await getAllPets();
    try {
      return pets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Pet>> getPetsByShelter(String shelterId) async {
    final pets = await getAllPets();
    return pets.where((p) => p.shelterId == shelterId).toList();
  }

  Future<Pet> createPet({
    required String name,
    required int age,
    required PetSpecies species,
    required PetSize size,
    required String description,
    required String city,
    required String shelterId,
    required String shelterName,
    List<String> imageUrls = const [],
    String? healthStatus,
  }) async {
    final pet = Pet(
      id: _uuid.v4(),
      name: name,
      age: age,
      species: species,
      size: size,
      description: description,
      status: PetStatus.available,
      city: city,
      imageUrls: imageUrls,
      healthStatus: healthStatus,
      shelterId: shelterId,
      shelterName: shelterName,
      createdAt: DateTime.now(),
    );

    final pets = await getAllPets();
    pets.add(pet);
    
    await _savePets(pets);
    return pet;
  }

  Future<Pet> updatePet(Pet pet) async {
    final pets = await getAllPets();
    final index = pets.indexWhere((p) => p.id == pet.id);
    
    if (index == -1) {
      throw Exception('Pet not found');
    }

    pets[index] = pet.copyWith(updatedAt: DateTime.now());
    await _savePets(pets);
    return pets[index];
  }

  Future<void> deletePet(String id) async {
    final pets = await getAllPets();
    pets.removeWhere((p) => p.id == id);
    await _savePets(pets);
  }

  Future<void> _savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _petsKey,
      jsonEncode(pets.map((p) => p.toJson()).toList()),
    );
  }

  Future<List<Pet>> _initializeSamplePets() async {
    final samplePets = [
      Pet(
        id: '1',
        name: 'Buddy',
        age: 2,
        species: PetSpecies.dog,
        size: PetSize.medium,
        description: 'A friendly and energetic dog who loves playing fetch and going for walks.',
        status: PetStatus.available,
        city: 'Istanbul',
        imageUrls: [],
        healthStatus: 'Vaccinated, Healthy',
        shelterId: 'shelter1',
        shelterName: 'Happy Paws Shelter',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Pet(
        id: '2',
        name: 'Whiskers',
        age: 1,
        species: PetSpecies.cat,
        size: PetSize.small,
        description: 'A playful kitten looking for a loving home.',
        status: PetStatus.available,
        city: 'Ankara',
        imageUrls: [],
        healthStatus: 'Vaccinated, Neutered',
        shelterId: 'shelter2',
        shelterName: 'Cat Care Center',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    await _savePets(samplePets);
    return samplePets;
  }
}

