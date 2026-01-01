import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_swe/core/models/pet.dart';
import 'package:flutter_application_swe/core/services/pet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PetService', () {
    late PetService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = PetService();
    });

    test('getAllPets initializes sample data when empty', () async {
      final pets = await service.getAllPets();
      expect(pets.length, 2);
      expect(pets.any((p) => p.name == 'Buddy'), isTrue);
      expect(pets.any((p) => p.name == 'Whiskers'), isTrue);

      final pets2 = await service.getAllPets();
      expect(pets2.length, 2);
    });

    test('searchPets filters by species', () async {
      await service.getAllPets();
      final dogs = await service.searchPets(species: PetSpecies.dog.name);
      expect(dogs.length, 1);
      expect(dogs.first.name, 'Buddy');
    });

    test('searchPets filters by city contains (case-insensitive)', () async {
      await service.getAllPets();
      final result = await service.searchPets(city: 'ist');
      expect(result.length, 1);
      expect(result.first.city, 'Istanbul');
    });

    test('createPet adds a pet with Available status', () async {
      await service.getAllPets();

      final created = await service.createPet(
        name: 'Luna',
        age: 3,
        species: PetSpecies.cat,
        size: PetSize.small,
        description: 'Calm cat',
        city: 'Izmir',
        shelterId: 'shelterX',
        shelterName: 'Shelter X',
      );

      expect(created.id, isNotEmpty);
      expect(created.status, PetStatus.available);

      final all = await service.getAllPets();
      expect(all.any((p) => p.id == created.id), isTrue);
    });

    test('updatePet updates existing pet and sets updatedAt', () async {
      final pets = await service.getAllPets();
      final pet = pets.first;

      final updated = await service.updatePet(
        pet.copyWith(name: 'Buddy Updated'),
      );

      expect(updated.name, 'Buddy Updated');
      expect(updated.updatedAt, isNotNull);

      final fetched = await service.getPetById(pet.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Buddy Updated');
      expect(fetched.updatedAt, isNotNull);
    });

    test('updatePet throws when pet does not exist', () async {
      await service.getAllPets();

      final missing = Pet(
        id: 'missing',
        name: 'X',
        age: 1,
        species: PetSpecies.other,
        size: PetSize.medium,
        description: 'NA',
        status: PetStatus.available,
        city: 'NA',
        imageUrls: const [],
        shelterId: 's0',
        shelterName: 'S0',
        createdAt: DateTime.now(),
      );

      expect(() => service.updatePet(missing), throwsA(isA<Exception>()));
    });

    test('deletePet removes a pet', () async {
      await service.getAllPets();
      await service.deletePet('1');

      final all = await service.getAllPets();
      expect(all.any((p) => p.id == '1'), isFalse);
    });
  });
}

