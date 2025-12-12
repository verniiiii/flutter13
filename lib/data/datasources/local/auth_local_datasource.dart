import 'package:prac13/core/models/user_model.dart';

class AuthLocalDataSource {
  User? _currentUser;

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> setCurrentUser(User? user) async {
    _currentUser = user;
  }

  Future<void> clearUser() async {
    _currentUser = null;
  }
}

