import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/models/pet.dart';

void main() {
  group('Pet Model', () {
    final samplePet = Pet(
      id: 'pet-1',
      name: 'Max',
      age: 24,
      species: PetSpecies.dog,
      size: PetSize.medium,
      description: 'A friendly dog',
      status: PetStatus.available,
      city: 'Istanbul',
      imageUrls: ['https://example.com/image.jpg'],
      healthStatus: 'Healthy',
      shelterId: 'shelter-1',
      shelterName: 'Happy Paws',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    group('constructor', () {
      test('creates Pet with all required fields', () {
        expect(samplePet.id, 'pet-1');
        expect(samplePet.name, 'Max');
        expect(samplePet.age, 24);
        expect(samplePet.species, PetSpecies.dog);
        expect(samplePet.size, PetSize.medium);
        expect(samplePet.status, PetStatus.available);
        expect(samplePet.city, 'Istanbul');
      });

      test('creates Pet with optional fields', () {
        expect(samplePet.healthStatus, 'Healthy');
        expect(samplePet.shelterId, 'shelter-1');
        expect(samplePet.shelterName, 'Happy Paws');
      });

      test('creates Pet without optional fields', () {
        final pet = Pet(
          id: 'pet-2',
          name: 'Luna',
          age: 12,
          species: PetSpecies.cat,
          size: PetSize.small,
          description: 'A cute cat',
          status: PetStatus.available,
          city: 'Ankara',
          imageUrls: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pet.healthStatus, isNull);
        expect(pet.shelterId, isNull);
        expect(pet.shelterName, isNull);
      });
    });

    group('toJson', () {
      test('converts Pet to JSON map correctly', () {
        final json = samplePet.toJson();

        expect(json['id'], 'pet-1');
        expect(json['name'], 'Max');
        expect(json['age'], 24);
        expect(json['species'], 'dog');
        expect(json['size'], 'medium');
        expect(json['status'], 'available');
        expect(json['city'], 'Istanbul');
        expect(json['imageUrls'], ['https://example.com/image.jpg']);
        expect(json['healthStatus'], 'Healthy');
        expect(json['shelterId'], 'shelter-1');
        expect(json['shelterName'], 'Happy Paws');
      });

      test('includes date fields as ISO8601 strings', () {
        final json = samplePet.toJson();

        expect(json['createdAt'], '2024-01-01T00:00:00.000');
        expect(json['updatedAt'], '2024-01-02T00:00:00.000');
      });
    });

    group('fromJson', () {
      test('creates Pet from JSON map correctly', () {
        final json = {
          'id': 'pet-3',
          'name': 'Charlie',
          'age': 6,
          'species': 'bird',
          'size': 'small',
          'description': 'A colorful bird',
          'status': 'available',
          'city': 'Izmir',
          'imageUrls': ['https://example.com/bird.jpg'],
          'healthStatus': 'Good',
          'shelterId': 'shelter-2',
          'shelterName': 'Bird Haven',
          'createdAt': '2024-03-01T10:00:00.000',
          'updatedAt': '2024-03-02T12:00:00.000',
        };

        final pet = Pet.fromJson(json);

        expect(pet.id, 'pet-3');
        expect(pet.name, 'Charlie');
        expect(pet.age, 6);
        expect(pet.species, PetSpecies.bird);
        expect(pet.size, PetSize.small);
        expect(pet.status, PetStatus.available);
        expect(pet.city, 'Izmir');
      });

      test('handles unknown species with fallback', () {
        final json = {
          'id': 'pet-4',
          'name': 'Unknown',
          'age': 12,
          'species': 'unknown_species',
          'size': 'medium',
          'description': 'Unknown animal',
          'status': 'available',
          'city': 'Bursa',
          'imageUrls': [],
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        final pet = Pet.fromJson(json);

        expect(pet.species, PetSpecies.other);
      });

      test('handles unknown status with fallback', () {
        final json = {
          'id': 'pet-5',
          'name': 'Test',
          'age': 12,
          'species': 'dog',
          'size': 'medium',
          'description': 'Test',
          'status': 'unknown_status',
          'city': 'Bursa',
          'imageUrls': [],
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        final pet = Pet.fromJson(json);

        expect(pet.status, PetStatus.available);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final updated = samplePet.copyWith(name: 'Buddy');

        expect(updated.name, 'Buddy');
        expect(updated.id, samplePet.id);
        expect(updated.age, samplePet.age);
      });

      test('creates copy with updated status', () {
        final updated = samplePet.copyWith(status: PetStatus.adopted);

        expect(updated.status, PetStatus.adopted);
        expect(updated.name, samplePet.name);
      });

      test('creates copy with multiple updates', () {
        final updated = samplePet.copyWith(
          name: 'Rocky',
          age: 36,
          city: 'Ankara',
        );

        expect(updated.name, 'Rocky');
        expect(updated.age, 36);
        expect(updated.city, 'Ankara');
        expect(updated.species, samplePet.species);
      });

      test('returns unchanged copy when no parameters provided', () {
        final updated = samplePet.copyWith();

        expect(updated.id, samplePet.id);
        expect(updated.name, samplePet.name);
        expect(updated.age, samplePet.age);
        expect(updated.species, samplePet.species);
      });
    });

    group('roundtrip', () {
      test('toJson and fromJson preserve all data', () {
        final json = samplePet.toJson();
        final restored = Pet.fromJson(json);

        expect(restored.id, samplePet.id);
        expect(restored.name, samplePet.name);
        expect(restored.age, samplePet.age);
        expect(restored.species, samplePet.species);
        expect(restored.size, samplePet.size);
        expect(restored.description, samplePet.description);
        expect(restored.status, samplePet.status);
        expect(restored.city, samplePet.city);
        expect(restored.imageUrls, samplePet.imageUrls);
        expect(restored.healthStatus, samplePet.healthStatus);
        expect(restored.shelterId, samplePet.shelterId);
        expect(restored.shelterName, samplePet.shelterName);
      });
    });
  });

  group('PetSpecies enum', () {
    test('contains expected values', () {
      expect(PetSpecies.values.length, 5);
      expect(PetSpecies.values, contains(PetSpecies.dog));
      expect(PetSpecies.values, contains(PetSpecies.cat));
      expect(PetSpecies.values, contains(PetSpecies.bird));
      expect(PetSpecies.values, contains(PetSpecies.rabbit));
      expect(PetSpecies.values, contains(PetSpecies.other));
    });
  });

  group('PetSize enum', () {
    test('contains expected values', () {
      expect(PetSize.values.length, 3);
      expect(PetSize.values, contains(PetSize.small));
      expect(PetSize.values, contains(PetSize.medium));
      expect(PetSize.values, contains(PetSize.large));
    });
  });

  group('PetStatus enum', () {
    test('contains expected values', () {
      expect(PetStatus.values.length, 3);
      expect(PetStatus.values, contains(PetStatus.available));
      expect(PetStatus.values, contains(PetStatus.pending));
      expect(PetStatus.values, contains(PetStatus.adopted));
    });
  });
}
