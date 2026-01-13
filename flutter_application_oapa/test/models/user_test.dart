import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/models/user.dart';

void main() {
  group('User Model', () {
    final sampleUser = User(
      id: 'user-1',
      name: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+905551234567',
      role: UserRole.adopter,
      profileImageUrl: 'https://example.com/profile.jpg',
      createdAt: DateTime(2024, 1, 1),
    );

    group('constructor', () {
      test('creates User with all required fields', () {
        expect(sampleUser.id, 'user-1');
        expect(sampleUser.name, 'John Doe');
        expect(sampleUser.email, 'john@example.com');
        expect(sampleUser.role, UserRole.adopter);
      });

      test('creates User with optional fields', () {
        expect(sampleUser.phoneNumber, '+905551234567');
        expect(sampleUser.profileImageUrl, 'https://example.com/profile.jpg');
      });

      test('creates User without optional fields', () {
        final user = User(
          id: 'user-2',
          name: 'Jane Doe',
          email: 'jane@example.com',
          role: UserRole.shelter,
          createdAt: DateTime.now(),
        );

        expect(user.phoneNumber, isNull);
        expect(user.profileImageUrl, isNull);
      });
    });

    group('toJson', () {
      test('converts User to JSON map correctly', () {
        final json = sampleUser.toJson();

        expect(json['id'], 'user-1');
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
        expect(json['phoneNumber'], '+905551234567');
        expect(json['role'], 'adopter');
        expect(json['profileImageUrl'], 'https://example.com/profile.jpg');
      });

      test('includes createdAt as ISO8601 string', () {
        final json = sampleUser.toJson();

        expect(json['createdAt'], '2024-01-01T00:00:00.000');
      });

      test('includes null values for optional fields', () {
        final user = User(
          id: 'user-3',
          name: 'Test User',
          email: 'test@example.com',
          role: UserRole.visitor,
          createdAt: DateTime.now(),
        );

        final json = user.toJson();

        expect(json['phoneNumber'], isNull);
        expect(json['profileImageUrl'], isNull);
      });
    });

    group('fromJson', () {
      test('creates User from JSON map correctly', () {
        final json = {
          'id': 'user-4',
          'name': 'Alice',
          'email': 'alice@example.com',
          'phoneNumber': '+905559876543',
          'role': 'admin',
          'profileImageUrl': 'https://example.com/alice.jpg',
          'createdAt': '2024-06-15T14:30:00.000',
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-4');
        expect(user.name, 'Alice');
        expect(user.email, 'alice@example.com');
        expect(user.phoneNumber, '+905559876543');
        expect(user.role, UserRole.admin);
        expect(user.profileImageUrl, 'https://example.com/alice.jpg');
      });

      test('handles unknown role with fallback', () {
        final json = {
          'id': 'user-5',
          'name': 'Unknown Role',
          'email': 'unknown@example.com',
          'role': 'unknown_role',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final user = User.fromJson(json);

        expect(user.role, UserRole.adopter);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'user-6',
          'name': 'No Phone',
          'email': 'nophone@example.com',
          'phoneNumber': null,
          'role': 'adopter',
          'profileImageUrl': null,
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final user = User.fromJson(json);

        expect(user.phoneNumber, isNull);
        expect(user.profileImageUrl, isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final updated = sampleUser.copyWith(name: 'John Smith');

        expect(updated.name, 'John Smith');
        expect(updated.id, sampleUser.id);
        expect(updated.email, sampleUser.email);
      });

      test('creates copy with updated role', () {
        final updated = sampleUser.copyWith(role: UserRole.shelter);

        expect(updated.role, UserRole.shelter);
        expect(updated.name, sampleUser.name);
      });

      test('creates copy with multiple updates', () {
        final updated = sampleUser.copyWith(
          name: 'Updated Name',
          email: 'updated@example.com',
          phoneNumber: '+901112223344',
        );

        expect(updated.name, 'Updated Name');
        expect(updated.email, 'updated@example.com');
        expect(updated.phoneNumber, '+901112223344');
        expect(updated.role, sampleUser.role);
      });

      test('returns unchanged copy when no parameters provided', () {
        final updated = sampleUser.copyWith();

        expect(updated.id, sampleUser.id);
        expect(updated.name, sampleUser.name);
        expect(updated.email, sampleUser.email);
        expect(updated.role, sampleUser.role);
      });
    });

    group('roundtrip', () {
      test('toJson and fromJson preserve all data', () {
        final json = sampleUser.toJson();
        final restored = User.fromJson(json);

        expect(restored.id, sampleUser.id);
        expect(restored.name, sampleUser.name);
        expect(restored.email, sampleUser.email);
        expect(restored.phoneNumber, sampleUser.phoneNumber);
        expect(restored.role, sampleUser.role);
        expect(restored.profileImageUrl, sampleUser.profileImageUrl);
      });
    });
  });

  group('UserRole enum', () {
    test('contains expected values', () {
      expect(UserRole.values.length, 4);
      expect(UserRole.values, contains(UserRole.visitor));
      expect(UserRole.values, contains(UserRole.adopter));
      expect(UserRole.values, contains(UserRole.shelter));
      expect(UserRole.values, contains(UserRole.admin));
    });

    test('enum names are correct', () {
      expect(UserRole.visitor.name, 'visitor');
      expect(UserRole.adopter.name, 'adopter');
      expect(UserRole.shelter.name, 'shelter');
      expect(UserRole.admin.name, 'admin');
    });
  });
}
