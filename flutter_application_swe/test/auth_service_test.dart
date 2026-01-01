import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_swe/core/models/user.dart';
import 'package:flutter_application_swe/core/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late AuthService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = AuthService();
    });

    test('register stores user and sets current user', () async {
      final user = await service.register(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'pass123',
        phoneNumber: '555-0101',
        role: UserRole.adopter,
      );

      expect(user, isNotNull);
      expect(user!.email, 'alice@example.com');
      expect(user.name, 'Alice');
      expect(user.role, UserRole.adopter);

      final current = await service.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.email, 'alice@example.com');
    });

    test('register rejects duplicate email', () async {
      await service.register(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'pass123',
      );

      expect(
        () => service.register(
          name: 'Alice2',
          email: 'alice@example.com',
          password: 'pass456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('login succeeds with correct password', () async {
      await service.register(
        name: 'Bob',
        email: 'bob@example.com',
        password: 'secret',
      );

      final user = await service.login('bob@example.com', 'secret');
      expect(user, isNotNull);
      expect(user!.email, 'bob@example.com');

      final current = await service.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.email, 'bob@example.com');
    });

    test('login fails with incorrect password', () async {
      await service.register(
        name: 'Bob',
        email: 'bob@example.com',
        password: 'secret',
      );

      expect(
        () => service.login('bob@example.com', 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('logout clears current user', () async {
      await service.register(
        name: 'Carol',
        email: 'carol@example.com',
        password: 'pass',
      );

      await service.logout();
      final current = await service.getCurrentUser();
      expect(current, isNull);
    });
  });
}

