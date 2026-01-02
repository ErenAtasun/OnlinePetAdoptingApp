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
  final RegExp _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  void reset({bool seedDemoData = false}) {
    _users.clear();
    _userData.clear();
    _initialized = false;
    if (seedDemoData) {
      initializeDemoData();
    }
  }

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
    _validateRegistrationInput(name, email, password, phoneNumber);

    final normalizedEmail = email.trim();
    final normalizedName = name.trim();
    final normalizedPhone = phoneNumber?.trim();

    if (_users.containsKey(normalizedEmail)) {
      return false; // User already exists
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: normalizedName,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      role: role,
      createdAt: DateTime.now(),
    );

    _users[normalizedEmail] = password;
    _userData[normalizedEmail] = user;
    return true;
  }

  Future<User?> login(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);

    final normalizedEmail = email.trim();
    final storedPassword = _users[normalizedEmail];
    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid credentials');
    }

    final user = _userData[normalizedEmail];
    if (user != null) {
      await _saveUser(user);
      return user;
    }

    throw Exception('User record not found');
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

  void _validateRegistrationInput(
    String name,
    String email,
    String password,
    String? phoneNumber,
  ) {
    if (name.trim().isEmpty) {
      throw const FormatException('Name is required');
    }
    _validateEmail(email);
    _validatePassword(password);
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      if (!_phoneRegex.hasMatch(phoneNumber.trim())) {
        throw const FormatException('Invalid phone number');
      }
    }
  }

  void _validateEmail(String email) {
    if (email.trim().isEmpty || !_emailRegex.hasMatch(email.trim())) {
      throw const FormatException('Invalid email address');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty || password.length < 6) {
      throw const FormatException('Password must be at least 6 characters');
    }
  }
}
