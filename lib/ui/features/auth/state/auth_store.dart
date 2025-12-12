import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/core/models/user_model.dart';
import 'package:prac13/domain/usecases/auth/login_usecase.dart';
import 'package:prac13/domain/usecases/auth/register_usecase.dart';
import 'package:prac13/domain/usecases/auth/logout_usecase.dart';
import 'package:prac13/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:prac13/domain/entities/user_entity.dart';
import 'package:prac13/data/datasources/remote/api/exceptions.dart';

import '../../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../../domain/usecases/auth/update_password_usecase.dart';

class AuthStore with ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  AuthStore({
    LoginUseCase? loginUseCase,
    RegisterUseCase? registerUseCase,
    LogoutUseCase? logoutUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
    UpdatePasswordUseCase? updatePasswordUseCase,
  })  : _loginUseCase = loginUseCase ?? GetIt.I<LoginUseCase>(),
        _registerUseCase = registerUseCase ?? GetIt.I<RegisterUseCase>(),
        _logoutUseCase = logoutUseCase ?? GetIt.I<LogoutUseCase>(),
        _getCurrentUserUseCase = getCurrentUserUseCase ?? GetIt.I<GetCurrentUserUseCase>(),
        _resetPasswordUseCase = resetPasswordUseCase ?? GetIt.I<ResetPasswordUseCase>(),
        _updatePasswordUseCase = updatePasswordUseCase ?? GetIt.I<UpdatePasswordUseCase>();

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
      // Валидация
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Пожалуйста, заполните все поля');
      }

      // Используем UseCase для входа
      final userEntity = await _loginUseCase.call(email, password);

      if (userEntity != null) {
        _currentUser = _entityToModel(userEntity);
        _isLoggedIn = true;
        _errorMessage = '';
      } else {
        throw Exception('Не удалось войти. Проверьте данные.');
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoggedIn = false;
      _currentUser = null;
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
      // Валидация
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('Пожалуйста, заполните все поля');
      }

      if (password != confirmPassword) {
        throw Exception('Пароли не совпадают');
      }

      if (password.length < 6) {
        throw Exception('Пароль должен содержать минимум 6 символов');
      }

      // Используем UseCase для регистрации
      final userEntity = await _registerUseCase.call(email, password, confirmPassword);

      if (userEntity != null) {
        _currentUser = _entityToModel(userEntity);
        _isLoggedIn = true;
        _errorMessage = '';
      } else {
        throw Exception('Не удалось зарегистрироваться. Попробуйте еще раз.');
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _logoutUseCase.call();
      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
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
      // Валидация
      if (email.isEmpty) {
        throw Exception('Введите email для восстановления пароля');
      }

      // Используем UseCase для восстановления пароля
      await _resetPasswordUseCase.call(email);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Валидация
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('Заполните все поля');
      }

      if (newPassword.length < 6) {
        throw Exception('Новый пароль должен содержать минимум 6 символов');
      }

      // Используем UseCase для смены пароля
      await _updatePasswordUseCase.call(oldPassword, newPassword);
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Загрузка текущего пользователя при старте приложения
  Future<void> loadCurrentUser() async {
    try {
      final userEntity = await _getCurrentUserUseCase.call();
      if (userEntity != null) {
        _currentUser = _entityToModel(userEntity);
        _isLoggedIn = true;
      } else {
        _currentUser = null;
        _isLoggedIn = false;
      }
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
    } finally {
      notifyListeners();
    }
  }

  /// Преобразование UserEntity в User модель
  User _entityToModel(UserEntity entity) {
    return User(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      isEmailVerified: entity.isEmailVerified,
      currency: entity.currency,
      themeMode: entity.themeMode,
      notificationsEnabled: entity.notificationsEnabled,
      biometricsEnabled: entity.biometricsEnabled,
      language: entity.language,
    );
  }

  /// Извлечение сообщения об ошибке из исключения
  String _extractErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }

    if (error is UnauthorizedException) {
      return 'Неверный email или пароль';
    }

    if (error is BadRequestException) {
      return error.message;
    }

    if (error is NoInternetException) {
      return 'Нет подключения к интернету';
    }

    if (error is TimeoutException) {
      return 'Превышено время ожидания. Проверьте подключение к интернету';
    }

    if (error is Exception) {
      final message = error.toString();
      // Убираем префикс "Exception: " если он есть
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }

    return 'Произошла неизвестная ошибка';
  }
}