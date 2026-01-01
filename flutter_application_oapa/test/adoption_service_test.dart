import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_oapa/models/adoption_request.dart';
import 'package:flutter_application_oapa/models/pet.dart';
import 'package:flutter_application_oapa/services/adoption_service.dart';
import 'package:flutter_application_oapa/services/notification_service.dart';
import 'package:flutter_application_oapa/services/pet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdoptionService', () {
    late AdoptionService adoptionService;
    late PetService petService;
    late NotificationService notificationService;

    setUp(() {
      adoptionService = AdoptionService();
      petService = PetService();
      petService.initializeDemoData();
      notificationService = NotificationService();
    });

    test('submitApplication creates a pending request and sets pet to pending', () async {
      final petId = '1';
      final pet = await petService.getPetById(petId);
      expect(pet, isNotNull);
      await petService.updatePet(pet!.copyWith(status: PetStatus.available));

      final shelterBefore =
          (await notificationService.getUserNotifications(pet.shelterId ?? '')).length;

      final request = await adoptionService.submitApplication(
        petId: petId,
        userId: 'user-${DateTime.now().microsecondsSinceEpoch}',
        userName: 'Applicant',
        userEmail: 'applicant@example.com',
        userPhoneNumber: '555-0101',
        message: 'I would like to adopt.',
      );

      expect(request.status, AdoptionStatus.pending);

      final petAfter = await petService.getPetById(petId);
      expect(petAfter, isNotNull);
      expect(petAfter!.status, PetStatus.pending);

      final shelterAfter =
          (await notificationService.getUserNotifications(pet.shelterId ?? '')).length;
      expect(shelterAfter, greaterThanOrEqualTo(shelterBefore + 1));
    });

    test('approveApplication adopts the pet and rejects other pending requests', () async {
      final petId = '3';
      final pet = await petService.getPetById(petId);
      expect(pet, isNotNull);
      await petService.updatePet(pet!.copyWith(status: PetStatus.available));

      final r1 = await adoptionService.submitApplication(
        petId: petId,
        userId: 'user1-${DateTime.now().microsecondsSinceEpoch}',
        userName: 'User One',
        userEmail: 'user1@example.com',
        message: 'Request 1',
      );

      final r2 = await adoptionService.submitApplication(
        petId: petId,
        userId: 'user2-${DateTime.now().microsecondsSinceEpoch}',
        userName: 'User Two',
        userEmail: 'user2@example.com',
        message: 'Request 2',
      );

      final user1Before =
          (await notificationService.getUserNotifications(r1.userId)).length;
      final user2Before =
          (await notificationService.getUserNotifications(r2.userId)).length;

      final approved = await adoptionService.approveApplication(r1.id, petId);
      expect(approved.status, AdoptionStatus.approved);

      final petAfter = await petService.getPetById(petId);
      expect(petAfter, isNotNull);
      expect(petAfter!.status, PetStatus.adopted);

      final applications = await adoptionService.getPetApplications(petId);
      final other = applications.firstWhere((a) => a.id == r2.id);
      expect(other.status, AdoptionStatus.rejected);

      final user1After =
          (await notificationService.getUserNotifications(r1.userId)).length;
      final user2After =
          (await notificationService.getUserNotifications(r2.userId)).length;

      expect(user1After, greaterThanOrEqualTo(user1Before + 1));
      expect(user2After, greaterThanOrEqualTo(user2Before + 1));
    });
  });
}

