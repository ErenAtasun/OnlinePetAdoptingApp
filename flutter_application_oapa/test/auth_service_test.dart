import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_oapa/models/user.dart';
import 'package:flutter_application_oapa/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String uniqueEmail(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}@example.com';

  group('AuthService', () {
    late AuthService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = AuthService();
      service.initializeDemoData();
    });

    test('register returns true and allows login', () async {
      final email = uniqueEmail('user');

      final registered = await service.register(
        name: 'Test User',
        email: email,
        password: 'pass123',
        phoneNumber: '555-0101',
        role: UserRole.adopter,
      );
      expect(registered, isTrue);

      final user = await service.login(email, 'pass123');
      expect(user, isNotNull);
      expect(user!.email, email);
      expect(user.role, UserRole.adopter);

      final current = await service.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.email, email);
    });

    test('register returns false for duplicate email', () async {
      final email = uniqueEmail('dup');

      final first = await service.register(
        name: 'User 1',
        email: email,
        password: 'p1',
      );
      final second = await service.register(
        name: 'User 2',
        email: email,
        password: 'p2',
      );

      expect(first, isTrue);
      expect(second, isFalse);
    });

    test('login returns null for wrong password', () async {
      final email = uniqueEmail('wrongpw');
      await service.register(
        name: 'User',
        email: email,
        password: 'correct',
      );

      final user = await service.login(email, 'incorrect');
      expect(user, isNull);
    });

    test('logout clears persisted current user', () async {
      final user = await service.login('admin@petapp.com', 'admin123');
      expect(user, isNotNull);

      await service.logout();

      final current = await service.getCurrentUser();
      expect(current, isNull);

      final loggedIn = await service.isLoggedIn();
      expect(loggedIn, isFalse);
    });
  });
}

