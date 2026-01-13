import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/models/pet.dart';
import 'package:flutter_application_oapa/services/pet_service.dart';

void main() {
  final petService = PetService();

  setUp(() {
    petService.reset(seedDemoData: true);
  });

  group('getPets', () {
    test('returns available pets when no filters are provided', () async {
      final pets = await petService.getPets();

      expect(pets, isNotEmpty);
      expect(pets.every((pet) => pet.status == PetStatus.available), isTrue);
    });

    test('filters cats in Istanbul correctly', () async {
      final pets = await petService.getPets(
        species: PetSpecies.cat,
        city: 'Istanbul',
      );

      expect(pets, isNotEmpty);
      expect(pets.every((pet) => pet.species == PetSpecies.cat), isTrue);
      expect(pets.every((pet) => pet.city.toLowerCase() == 'istanbul'), isTrue);
    });

    test('filters by size correctly', () async {
      final pets = await petService.getPets(size: PetSize.small);

      expect(pets, isNotEmpty);
      expect(pets.every((pet) => pet.size == PetSize.small), isTrue);
    });

    test('filters by age range correctly', () async {
      final pets = await petService.getPets(minAge: 12, maxAge: 36);

      expect(pets, isNotEmpty);
      expect(
        pets.every((pet) => pet.age >= 12 && pet.age <= 36),
        isTrue,
      );
    });

    test('filters by search query in name', () async {
      final allPets = await petService.getPets();
      if (allPets.isNotEmpty) {
        final firstPetName = allPets.first.name;
        final searchTerm = firstPetName.substring(0, 2).toLowerCase();

        final filteredPets = await petService.getPets(searchQuery: searchTerm);

        expect(filteredPets, isNotEmpty);
      }
    });

    test('excludes non-available pets from listing', () async {
      final original = petService.allPets.first;
      await petService.updatePet(original.copyWith(status: PetStatus.pending));

      final pets = await petService.getPets();
      expect(pets.every((pet) => pet.status == PetStatus.available), isTrue);
      expect(pets.any((pet) => pet.id == original.id), isFalse);
    });

    test('returns empty list when no pets match criteria', () async {
      final pets = await petService.getPets(
        species: PetSpecies.bird,
        city: 'NonExistentCity',
      );

      expect(pets, isEmpty);
    });
  });

  group('getPetById', () {
    test('returns pet when found', () async {
      final allPets = petService.allPets;
      if (allPets.isNotEmpty) {
        final pet = await petService.getPetById(allPets.first.id);
        expect(pet, isNotNull);
        expect(pet!.id, allPets.first.id);
      }
    });

    test('returns null when pet is not found', () async {
      final pet = await petService.getPetById('999');
      expect(pet, isNull);
    });

    test('returns null for empty id', () async {
      final pet = await petService.getPetById('');
      expect(pet, isNull);
    });
  });

  group('getPetsByShelter', () {
    test('returns pets for specific shelter', () async {
      final pets = await petService.getPetsByShelter('shelter1');

      expect(pets, isNotEmpty);
      expect(pets.every((pet) => pet.shelterId == 'shelter1'), isTrue);
    });

    test('returns empty list for non-existent shelter', () async {
      final pets = await petService.getPetsByShelter('non-existent-shelter');

      expect(pets, isEmpty);
    });
  });

  group('createPet', () {
    test('adds new pet to the list', () async {
      final initialCount = petService.allPets.length;

      final newPet = Pet(
        id: 'new-pet-1',
        name: 'Fluffy',
        age: 6,
        species: PetSpecies.rabbit,
        size: PetSize.small,
        description: 'A fluffy rabbit',
        status: PetStatus.available,
        city: 'Ankara',
        imageUrls: [],
        shelterId: 'shelter1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await petService.createPet(newPet);

      expect(petService.allPets.length, initialCount + 1);
      final createdPet = await petService.getPetById('new-pet-1');
      expect(createdPet, isNotNull);
      expect(createdPet!.name, 'Fluffy');
    });
  });

  group('updatePet', () {
    test('updates existing pet', () async {
      final original = petService.allPets.first;
      final updated = original.copyWith(name: 'Updated Name');

      await petService.updatePet(updated);

      final fetched = await petService.getPetById(original.id);
      expect(fetched!.name, 'Updated Name');
    });

    test('updates pet status correctly', () async {
      final original = petService.allPets.first;
      final updated = original.copyWith(status: PetStatus.adopted);

      await petService.updatePet(updated);

      final fetched = await petService.getPetById(original.id);
      expect(fetched!.status, PetStatus.adopted);
    });
  });

  group('deletePet', () {
    test('removes pet from the list', () async {
      final initialCount = petService.allPets.length;
      final petToDelete = petService.allPets.first;

      await petService.deletePet(petToDelete.id);

      expect(petService.allPets.length, initialCount - 1);
      final deleted = await petService.getPetById(petToDelete.id);
      expect(deleted, isNull);
    });
  });

  group('reset', () {
    test('clears all pets when seedDemoData is false', () {
      petService.reset(seedDemoData: false);

      expect(petService.allPets, isEmpty);
    });

    test('restores demo data when seedDemoData is true', () {
      petService.reset(seedDemoData: false);
      expect(petService.allPets, isEmpty);

      petService.reset(seedDemoData: true);
      expect(petService.allPets, isNotEmpty);
    });
  });
}

