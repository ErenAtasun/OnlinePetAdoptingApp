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

  test('register succeeds with valid email and phone', () async {
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

  test('register throws for invalid email format', () async {
    expect(
      () => authService.register(
        name: 'Jane Doe',
        email: 'not-an-email',
        password: 'secret1',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('login returns user for correct credentials', () async {
    await authService.register(
      name: 'John Smith',
      email: 'john@example.com',
      password: 'secret1',
    );

    final user = await authService.login('john@example.com', 'secret1');
    expect(user, isNotNull);
    expect(user!.role, UserRole.adopter);
  });

  test('login throws for wrong password', () async {
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
}

