import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_oapa/models/pet.dart';
import 'package:flutter_application_oapa/services/pet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PetService', () {
    late PetService service;

    setUp(() {
      service = PetService();
      service.initializeDemoData();
    });

    test('getPets returns available pets', () async {
      final pets = await service.getPets();
      expect(pets, isNotEmpty);
      expect(pets.every((p) => p.status == PetStatus.available), isTrue);
    });

    test('getPets filters by species', () async {
      final cats = await service.getPets(species: PetSpecies.cat);
      expect(cats, isNotEmpty);
      expect(cats.every((p) => p.species == PetSpecies.cat), isTrue);
      expect(cats.every((p) => p.status == PetStatus.available), isTrue);
    });

    test('createPet, updatePet, and deletePet work for a new pet', () async {
      final id = 'test-${DateTime.now().microsecondsSinceEpoch}';
      final createdAt = DateTime.now();

      final pet = Pet(
        id: id,
        name: 'Test Pet',
        age: 10,
        species: PetSpecies.other,
        size: PetSize.medium,
        description: 'A test pet',
        status: PetStatus.available,
        city: 'Test City',
        imageUrls: const [],
        shelterId: 'shelter-test',
        shelterName: 'Shelter Test',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      await service.createPet(pet);

      final fetched = await service.getPetById(id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Test Pet');

      final updated = await service.updatePet(fetched.copyWith(name: 'Updated'));
      expect(updated.name, 'Updated');
      expect(updated.updatedAt.isAfter(createdAt) || updated.updatedAt.isAtSameMomentAs(createdAt), isTrue);

      await service.deletePet(id);
      final afterDelete = await service.getPetById(id);
      expect(afterDelete, isNull);
    });
  });
}

