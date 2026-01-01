import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_swe/core/models/adoption_request.dart';
import 'package:flutter_application_swe/core/models/pet.dart';
import 'package:flutter_application_swe/core/services/adoption_service.dart';
import 'package:flutter_application_swe/core/services/notification_service.dart';
import 'package:flutter_application_swe/core/services/pet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdoptionService', () {
    late AdoptionService adoptionService;
    late PetService petService;
    late NotificationService notificationService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      adoptionService = AdoptionService();
      petService = PetService();
      notificationService = NotificationService();
    });

    test(
      'submitApplication creates request, sets pet to Pending, creates notifications',
      () async {
        await petService.getAllPets();

        final request = await adoptionService.submitApplication(
          petId: '1',
          userId: 'user1',
          userName: 'Alice',
          userEmail: 'alice@example.com',
          userPhone: '555-0101',
          message: 'I have a suitable home.',
        );

        expect(request.petId, '1');
        expect(request.userId, 'user1');
        expect(request.status, AdoptionRequestStatus.pending);

        final pet = await petService.getPetById('1');
        expect(pet, isNotNull);
        expect(pet!.status, PetStatus.pending);

        final shelterNotes =
            await notificationService.getNotificationsByUser('shelter1');
        expect(
          shelterNotes.any((n) => n.type == 'application_received'),
          isTrue,
        );

        final userNotes =
            await notificationService.getNotificationsByUser('user1');
        expect(
          userNotes.any((n) => n.type == 'application_submitted'),
          isTrue,
        );
      },
    );

    test('submitApplication rejects duplicate pending application by same user',
        () async {
      await petService.getAllPets();

      await adoptionService.submitApplication(
        petId: '1',
        userId: 'user1',
        userName: 'Alice',
        userEmail: 'alice@example.com',
      );

      expect(
        () => adoptionService.submitApplication(
          petId: '1',
          userId: 'user1',
          userName: 'Alice',
          userEmail: 'alice@example.com',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'updateRequestStatus approved sets pet Adopted and rejects other pending requests (seeded)',
      () async {
        await petService.getAllPets();

        final pet = await petService.getPetById('1');
        final prefs = await SharedPreferences.getInstance();

        final r1 = AdoptionRequest(
          id: 'r1',
          petId: '1',
          userId: 'user1',
          userName: 'U1',
          userEmail: 'u1@example.com',
          status: AdoptionRequestStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final r2 = AdoptionRequest(
          id: 'r2',
          petId: '1',
          userId: 'user2',
          userName: 'U2',
          userEmail: 'u2@example.com',
          status: AdoptionRequestStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await prefs.setString(
          'adoption_requests',
          jsonEncode([r1.toJson(), r2.toJson()]),
        );

        await petService.updatePet(pet!.copyWith(status: PetStatus.pending));

        final updated = await adoptionService.updateRequestStatus(
          requestId: 'r1',
          status: AdoptionRequestStatus.approved,
          shelterId: pet.shelterId,
        );

        expect(updated.status, AdoptionRequestStatus.approved);

        final petAfter = await petService.getPetById('1');
        expect(petAfter, isNotNull);
        expect(petAfter!.status, PetStatus.adopted);

        final all = await adoptionService.getAllRequests();
        final other = all.firstWhere((r) => r.id == 'r2');
        expect(other.status, AdoptionRequestStatus.rejected);

        final notesUser2 =
            await notificationService.getNotificationsByUser('user2');
        expect(notesUser2.any((n) => n.type == 'adoption_status'), isTrue);

        final notesUser1 =
            await notificationService.getNotificationsByUser('user1');
        expect(notesUser1.any((n) => n.type == 'adoption_status'), isTrue);
      },
    );
  });
}

