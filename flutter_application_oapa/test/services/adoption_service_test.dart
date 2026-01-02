import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/models/adoption_request.dart';
import 'package:flutter_application_oapa/models/pet.dart';
import 'package:flutter_application_oapa/services/adoption_service.dart';
import 'package:flutter_application_oapa/services/notification_service.dart';
import 'package:flutter_application_oapa/services/pet_service.dart';

void main() {
  final petService = PetService();
  final notificationService = NotificationService();
  final adoptionService = AdoptionService();

  setUp(() {
    petService.reset(seedDemoData: true);
    adoptionService.reset();
    notificationService.reset();
  });

  test('submitApplication creates pending request when pet is available', () async {
    final request = await adoptionService.submitApplication(
      petId: '1',
      userId: 'user-1',
      userName: 'User One',
      userEmail: 'user1@example.com',
      userPhoneNumber: '5551234',
      message:
          'I love caring for pets and have a safe home with a garden and plenty of time to play.',
    );

    expect(request.status, AdoptionStatus.pending);
    final pet = await petService.getPetById('1');
    expect(pet?.status, PetStatus.pending);

    final shelterNotifications = notificationService.notifications
        .where((n) => n.userId == pet?.shelterId)
        .toList();
    expect(shelterNotifications, isNotEmpty);
  });

  test('prevents the same user from applying to the same pet twice', () async {
    await adoptionService.submitApplication(
      petId: '2',
      userId: 'user-duplicate',
      userName: 'Duplicate User',
      userEmail: 'duplicate@example.com',
      message: 'Ready to adopt and provide a loving home.',
    );

    expect(
      () => adoptionService.submitApplication(
        petId: '2',
        userId: 'user-duplicate',
        userName: 'Duplicate User',
        userEmail: 'duplicate@example.com',
        message: 'Trying again should fail.',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('approves application and rejects other pending ones', () async {
    final primary = await adoptionService.submitApplication(
      petId: '3',
      userId: 'user-primary',
      userName: 'Primary User',
      userEmail: 'primary@example.com',
      message: 'Looking forward to adopting Max.',
    );
    final secondary = await adoptionService.submitApplication(
      petId: '3',
      userId: 'user-secondary',
      userName: 'Secondary User',
      userEmail: 'secondary@example.com',
      message: 'Another user applying for Max.',
    );

    final approved = await adoptionService.approveApplication(
      requestId: primary.id,
      petId: primary.petId,
      shelterId: 'shelter1',
    );

    expect(approved.status, AdoptionStatus.approved);
    final updatedPet = await petService.getPetById(primary.petId);
    expect(updatedPet?.status, PetStatus.adopted);

    final rejectedOther = adoptionService.requests
        .firstWhere((r) => r.id == secondary.id);
    expect(rejectedOther.status, AdoptionStatus.rejected);

    final rejectionNotification = notificationService.notifications.where(
      (n) => n.userId == secondary.userId && n.type == 'adoption_status',
    );
    expect(rejectionNotification, isNotEmpty);
  });

  test('throws when another shelter tries to approve the request', () async {
    final request = await adoptionService.submitApplication(
      petId: '4',
      userId: 'user-unauthorized',
      userName: 'Unauthorized User',
      userEmail: 'unauthorized@example.com',
      message: 'Attempting unauthorized approval.',
    );

    expect(
      () => adoptionService.approveApplication(
        requestId: request.id,
        petId: request.petId,
        shelterId: 'different-shelter',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects application and makes pet available when no other pending', () async {
    final request = await adoptionService.submitApplication(
      petId: '5',
      userId: 'user-reject',
      userName: 'Reject User',
      userEmail: 'reject@example.com',
      message: 'Please consider my application.',
    );

    final rejected = await adoptionService.rejectApplication(
      requestId: request.id,
      shelterId: 'shelter1',
      reason: 'Incomplete details',
    );

    expect(rejected.status, AdoptionStatus.rejected);
    final pet = await petService.getPetById(request.petId);
    expect(pet?.status, PetStatus.available);

    final notification = notificationService.notifications.where(
      (n) => n.userId == request.userId && n.type == 'adoption_status',
    );
    expect(notification, isNotEmpty);
  });
}

