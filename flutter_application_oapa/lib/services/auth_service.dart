import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // In-memory storage for users (in real app, this would be API calls)
  final Map<String, String> _users = {}; // email -> password
  final Map<String, User> _userData = {}; // email -> User
  bool _initialized = false;

  // Initialize with some demo data
  void initializeDemoData() {
    if (_initialized) return; // Already initialized
    _initialized = true;
    // Demo admin user
    final admin = User(
      id: 'admin1',
      name: 'Admin User',
      email: 'admin@petapp.com',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );
    _userData['admin@petapp.com'] = admin;
    _users['admin@petapp.com'] = 'admin123';

    // Demo shelter user
    final shelter = User(
      id: 'shelter1',
      name: 'Happy Paws Shelter',
      email: 'shelter@petapp.com',
      role: UserRole.shelter,
      createdAt: DateTime.now(),
    );
    _userData['shelter@petapp.com'] = shelter;
    _users['shelter@petapp.com'] = 'shelter123';
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    UserRole role = UserRole.adopter,
  }) async {
    if (_users.containsKey(email)) {
      return false; // User already exists
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
    );

    _users[email] = password;
    _userData[email] = user;
    return true;
  }

  Future<User?> login(String email, String password) async {
    if (_users[email] == password) {
      final user = _userData[email];
      if (user != null) {
        await _saveUser(user);
        return user;
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> updateUser(User user) async {
    _userData[user.email] = user;
    await _saveUser(user);
  }
}

