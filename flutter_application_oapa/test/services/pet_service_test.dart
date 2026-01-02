import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/models/pet.dart';
import 'package:flutter_application_oapa/services/pet_service.dart';

void main() {
  final petService = PetService();

  setUp(() {
    petService.reset(seedDemoData: true);
  });

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

  test('returns null when pet is not found', () async {
    final pet = await petService.getPetById('999');
    expect(pet, isNull);
  });

  test('excludes non-available pets from listing', () async {
    final original = petService.allPets.first;
    await petService.updatePet(original.copyWith(status: PetStatus.pending));

    final pets = await petService.getPets();
    expect(pets.every((pet) => pet.status == PetStatus.available), isTrue);
    expect(pets.any((pet) => pet.id == original.id), isFalse);
  });
}

