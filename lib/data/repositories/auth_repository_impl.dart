import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource? remoteDataSource;

  AuthRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  UserEntity _modelToEntity(User model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      phoneNumber: model.phoneNumber,
      photoUrl: model.photoUrl,
      createdAt: model.createdAt,
      isEmailVerified: model.isEmailVerified,
      currency: model.currency,
      themeMode: model.themeMode,
      notificationsEnabled: model.notificationsEnabled,
      biometricsEnabled: model.biometricsEnabled,
      language: model.language,
    );
  }

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

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        final user = await remoteDataSource!.signIn(
          email: email,
          password: password,
        );
        // Сохраняем пользователя локально для кеширования
        await localDataSource.setCurrentUser(user);
        return _modelToEntity(user);
      } catch (e) {
        // Если ошибка сети, пробуем локальную логику как fallback
        // или пробрасываем ошибку дальше
        rethrow;
      }
    }

    // Существующая локальная логика (fallback)
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
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
      await localDataSource.setCurrentUser(user);
      return _modelToEntity(user);
    } else {
      throw Exception('Пожалуйста, заполните все поля');
    }
  }

  @override
  Future<UserEntity?> register(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw Exception('Пароли не совпадают');
    }

    if (password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        final user = await remoteDataSource!.signUp(
          email: email,
          password: password,
        );
        // Сохраняем пользователя локально для кеширования
        await localDataSource.setCurrentUser(user);
        return _modelToEntity(user);
      } catch (e) {
        print(e.toString());
        rethrow;
      }
    }

    // Существующая локальная логика (fallback)
    await Future.delayed(const Duration(seconds: 2));

    final user = User(
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
    await localDataSource.setCurrentUser(user);
    return _modelToEntity(user);
  }

  @override
  Future<void> logout() async {
    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.logout();
      } catch (e) {
        // Даже если запрос не удался, очищаем локальные данные
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await localDataSource.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Сначала пробуем получить из локального хранилища
    final localUser = await localDataSource.getCurrentUser();
    
    // Если есть Remote DataSource, пробуем получить актуальные данные с сервера
    if (remoteDataSource != null) {
      try {
        final remoteUser = await remoteDataSource!.getCurrentUser();
        // Обновляем локальный кеш
        await localDataSource.setCurrentUser(remoteUser);
        return _modelToEntity(remoteUser);
      } catch (e) {
        // Если не удалось получить с сервера, возвращаем локальные данные
        return localUser != null ? _modelToEntity(localUser) : null;
      }
    }

    return localUser != null ? _modelToEntity(localUser) : null;
  }

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updateProfile(
          displayName: displayName,
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
        );
        // Обновляем локальный кеш
        await localDataSource.setCurrentUser(updated);
        return _modelToEntity(updated);
      } catch (e) {
        rethrow;
      }
    }

    // Существующая локальная логика (fallback)
    final current = await localDataSource.getCurrentUser();
    if (current == null) {
      throw Exception('User not found');
    }

    await Future.delayed(const Duration(seconds: 1));

    final updated = current.copyWith(
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );
    await localDataSource.setCurrentUser(updated);
    return _modelToEntity(updated);
  }

  @override
  Future<UserEntity> updateSettings({
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
    String? language,
  }) async {
    final current = await localDataSource.getCurrentUser();
    if (current == null) {
      throw Exception('User not found');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final updated = current.copyWith(
      currency: currency,
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      biometricsEnabled: biometricsEnabled,
      language: language,
    );
    await localDataSource.setCurrentUser(updated);
    return _modelToEntity(updated);
  }

  @override
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Заполните все поля');
    }

    if (newPassword.length < 6) {
      throw Exception('Новый пароль должен содержать минимум 6 символов');
    }

    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.updatePassword(oldPassword, newPassword);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('Remote data source not available');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw Exception('Введите email для восстановления пароля');
    }

    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.resetPassword(email);
      } catch (e) {
        rethrow;
      }
    } else {
      // Fallback для локальной логики
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}

