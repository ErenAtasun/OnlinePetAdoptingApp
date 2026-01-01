import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _loadCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    UserRole role = UserRole.adopter,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
      );

      if (success) {
        // Auto login after registration
        final user = await _authService.login(email, password);
        if (user != null) {
          _currentUser = user;
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    await _authService.updateUser(user);
    _currentUser = user;
    notifyListeners();
  }
}

