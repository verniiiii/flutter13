import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/user_model.dart';

class AuthStore with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasError => _errorMessage.isNotEmpty;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          email: email,
          displayName: email.split('@').first,
          phoneNumber: '+7 (999) 999-99-99',
          photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
          createdAt: DateTime.now(),
          isEmailVerified: true,
          currency: Currency.rub,
          themeMode: ThemeMode.system,
          notificationsEnabled: true,
          biometricsEnabled: false,
          language: 'ru',
        );
        _isLoggedIn = true;
        _errorMessage = '';
      } else {
        throw Exception('Пожалуйста, заполните все поля');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (password != confirmPassword) {
        throw Exception('Пароли не совпадают');
      }

      if (password.length < 6) {
        throw Exception('Пароль должен содержать минимум 6 символов');
      }

      await Future.delayed(const Duration(seconds: 2));

      _currentUser = User(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        email: email,
        displayName: email.split('@').first,
        phoneNumber: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        isEmailVerified: false,
        currency: Currency.rub,
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        biometricsEnabled: false,
        language: 'ru',
      );
      _isLoggedIn = true;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings({
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
    String? language,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        currency: currency,
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        biometricsEnabled: biometricsEnabled,
        language: language,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (email.isEmpty) {
        throw Exception('Введите email для восстановления пароля');
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}