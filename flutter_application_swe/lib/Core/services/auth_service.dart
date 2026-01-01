import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    UserRole role = UserRole.adopter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    final usersJson = prefs.getString(_usersKey);
    final List<User> users = usersJson != null
        ? (jsonDecode(usersJson) as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    // Check if email already exists
    if (users.any((u) => u.email == email)) {
      throw Exception('Email already registered');
    }

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
    );

    // Hash password (simple implementation for demo)
    final passwordHash = _hashPassword(password);

    // Store user with password
    users.add(user);
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    
    // Store password separately (in real app, use secure storage)
    await prefs.setString('password_${user.id}', passwordHash);

    // Auto login after registration
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<User?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      throw Exception('No users found');
    }

    final List<Map<String, dynamic>> usersList =
        (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>();
    
    final users = usersList.map((e) => User.fromJson(e)).toList();
    
    final user = users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Invalid credentials'),
    );

    // Verify password
    final storedPasswordHash = prefs.getString('password_${user.id}');
    final inputPasswordHash = _hashPassword(password);
    
    if (storedPasswordHash != inputPasswordHash) {
      throw Exception('Invalid credentials');
    }

    // Store current user
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) {
      return null;
    }

    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

