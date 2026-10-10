import 'package:flutter/foundation.dart';

/// Represents a user role in the system.
enum UserRole {
  passenger,
  controlRoom,
  technician,
}

/// Represents a logged-in user.
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

/// Simple in-memory authentication service with dummy users.
/// No backend required — purely for demo / hackathon use.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Dummy user database
  static const List<Map<String, String>> _dummyUsers = [
    // Control Room operators
    {
      'id': 'CR-001',
      'name': 'Priya Mehta',
      'email': 'priya@metro.in',
      'password': 'admin123',
      'role': 'controlRoom',
    },
    {
      'id': 'CR-002',
      'name': 'Raj Kumar',
      'email': 'raj@metro.in',
      'password': 'admin123',
      'role': 'controlRoom',
    },
    // Technicians
    {
      'id': 'TECH-001',
      'name': 'Vikas Sharma',
      'email': 'vikas@metro.in',
      'password': 'tech123',
      'role': 'technician',
    },
    {
      'id': 'TECH-002',
      'name': 'Amit Patel',
      'email': 'amit@metro.in',
      'password': 'tech123',
      'role': 'technician',
    },
  ];

  /// Attempts login. Returns error message if failed, null on success.
  Future<String?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    for (final user in _dummyUsers) {
      if (user['email']!.toLowerCase() == trimmedEmail &&
          user['password'] == trimmedPassword) {
        _currentUser = AppUser(
          id: user['id']!,
          name: user['name']!,
          email: user['email']!,
          role: user['role'] == 'controlRoom'
              ? UserRole.controlRoom
              : UserRole.technician,
        );
        notifyListeners();
        return null; // success
      }
    }

    return 'Invalid email or password. Try priya@metro.in / admin123';
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Get list of demo credentials for display on login screen
  static List<Map<String, String>> getDemoCredentials(UserRole role) {
    return _dummyUsers
        .where((u) =>
            (role == UserRole.controlRoom && u['role'] == 'controlRoom') ||
            (role == UserRole.technician && u['role'] == 'technician'))
        .map((u) => {'email': u['email']!, 'password': u['password']!})
        .toList();
  }
}
