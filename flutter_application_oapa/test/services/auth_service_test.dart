import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_oapa/models/user.dart';
import 'package:flutter_application_oapa/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authService.reset();
  });

  group('register', () {
    test('succeeds with valid email and phone', () async {
      final success = await authService.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'secret1',
        phoneNumber: '+905551112233',
        role: UserRole.adopter,
      );

      expect(success, isTrue);
      final user = await authService.login('jane@example.com', 'secret1');
      expect(user, isNotNull);
      expect(user!.email, 'jane@example.com');
    });

    test('succeeds without optional phone number', () async {
      final success = await authService.register(
        name: 'No Phone User',
        email: 'nophone@example.com',
        password: 'secret123',
      );

      expect(success, isTrue);
    });

    test('throws for invalid email format', () async {
      expect(
        () => authService.register(
          name: 'Jane Doe',
          email: 'not-an-email',
          password: 'secret1',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for empty email', () async {
      expect(
        () => authService.register(
          name: 'Test User',
          email: '',
          password: 'secret1',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for empty name', () async {
      expect(
        () => authService.register(
          name: '',
          email: 'valid@example.com',
          password: 'secret1',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for short password', () async {
      expect(
        () => authService.register(
          name: 'Test User',
          email: 'valid@example.com',
          password: '12345',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for invalid phone number format', () async {
      expect(
        () => authService.register(
          name: 'Test User',
          email: 'valid@example.com',
          password: 'secret1',
          phoneNumber: 'invalid-phone',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns false for duplicate email', () async {
      await authService.register(
        name: 'First User',
        email: 'duplicate@example.com',
        password: 'secret1',
      );

      final result = await authService.register(
        name: 'Second User',
        email: 'duplicate@example.com',
        password: 'secret2',
      );

      expect(result, isFalse);
    });

    test('creates user with correct role', () async {
      await authService.register(
        name: 'Shelter Owner',
        email: 'shelter@example.com',
        password: 'secret1',
        role: UserRole.shelter,
      );

      final user = await authService.login('shelter@example.com', 'secret1');
      expect(user!.role, UserRole.shelter);
    });
  });

  group('login', () {
    test('returns user for correct credentials', () async {
      await authService.register(
        name: 'John Smith',
        email: 'john@example.com',
        password: 'secret1',
      );

      final user = await authService.login('john@example.com', 'secret1');
      expect(user, isNotNull);
      expect(user!.role, UserRole.adopter);
    });

    test('throws for wrong password', () async {
      await authService.register(
        name: 'Wrong Password',
        email: 'wrong@example.com',
        password: 'secret1',
      );

      expect(
        () => authService.login('wrong@example.com', 'badpass'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws for non-existent user', () async {
      expect(
        () => authService.login('nonexistent@example.com', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws for invalid email format', () async {
      expect(
        () => authService.login('invalid-email', 'password'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for empty password', () async {
      expect(
        () => authService.login('valid@example.com', ''),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('logout', () {
    test('clears user session', () async {
      await authService.register(
        name: 'Logout Test',
        email: 'logout@example.com',
        password: 'secret1',
      );
      await authService.login('logout@example.com', 'secret1');

      await authService.logout();

      final isLoggedIn = await authService.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });
  });

  group('getCurrentUser', () {
    test('returns null when not logged in', () async {
      final user = await authService.getCurrentUser();
      expect(user, isNull);
    });

    test('returns user after login', () async {
      await authService.register(
        name: 'Current User',
        email: 'current@example.com',
        password: 'secret1',
      );
      await authService.login('current@example.com', 'secret1');

      final user = await authService.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.email, 'current@example.com');
    });
  });

  group('isLoggedIn', () {
    test('returns false when not logged in', () async {
      final result = await authService.isLoggedIn();
      expect(result, isFalse);
    });

    test('returns true after login', () async {
      await authService.register(
        name: 'Login Test',
        email: 'logintest@example.com',
        password: 'secret1',
      );
      await authService.login('logintest@example.com', 'secret1');

      final result = await authService.isLoggedIn();
      expect(result, isTrue);
    });
  });

  group('initializeDemoData', () {
    test('creates demo users', () async {
      authService.initializeDemoData();

      // Try to login with demo admin credentials
      final admin = await authService.login('admin@petapp.com', 'admin123');
      expect(admin, isNotNull);
      expect(admin!.role, UserRole.admin);

      // Try to login with demo shelter credentials
      final shelter = await authService.login('shelter@petapp.com', 'shelter123');
      expect(shelter, isNotNull);
      expect(shelter!.role, UserRole.shelter);
    });
  });

  group('reset', () {
    test('clears all registered users', () async {
      await authService.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'secret1',
      );

      authService.reset();

      expect(
        () => authService.login('test@example.com', 'secret1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

