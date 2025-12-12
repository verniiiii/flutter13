import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import 'api/supabase_auth_client.dart';
import 'dto/auth_dto.dart';
import 'api/exceptions.dart';

class AuthRemoteDataSource {
  final SupabaseAuthClient _client;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthRemoteDataSource({
    required SupabaseAuthClient client,
    required FlutterSecureStorage secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage;

  /// Регистрация нового пользователя
  Future<User> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      final request = SignUpRequestDto(
        email: email,
        password: password,
        userMetadata: userMetadata,
      );

      final response = await _client.signUp(request);

      // Сохраняем токены
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Преобразуем DTO в модель пользователя
      return _userDtoToModel(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Вход пользователя
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final request = SignInRequestDto(
        email: email,
        password: password,
      );

      final response = await _client.signIn(request);

      // Сохраняем токены
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Преобразуем DTO в модель пользователя
      return _userDtoToModel(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение данных текущего пользователя
  Future<User> getCurrentUser() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final response = await _client.getUser(accessToken: accessToken);
      return _userDtoToModel(response.user);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Обновление токена доступа
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        throw UnauthorizedException('Refresh token не найден');
      }

      final request = RefreshTokenRequestDto(refreshToken: refreshToken);
      final response = await _client.refreshToken(request);

      // Сохраняем новые токены
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken ?? refreshToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Выход пользователя
  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      await _client.logout(accessToken: accessToken);
      await _clearTokens();
    } catch (e) {
      // Даже если запрос не удался, очищаем токены локально
      await _clearTokens();
      throw _handleError(e);
    }
  }

  /// Обновление пароля пользователя
  Future<User> updatePassword(String newPassword) async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final request = UpdatePasswordRequestDto(password: newPassword);
      final response = await _client.updatePassword(
        request,
        accessToken: accessToken,
      );
      return _userDtoToModel(response.user);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Обновление профиля пользователя
  Future<User> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final userMetadata = <String, dynamic>{};
      if (displayName != null) userMetadata['display_name'] = displayName;
      if (phoneNumber != null) userMetadata['phone_number'] = phoneNumber;
      if (photoUrl != null) userMetadata['photo_url'] = photoUrl;

      final request = UpdateProfileRequestDto(
        userMetadata: userMetadata.isNotEmpty ? userMetadata : null,
      );

      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final response = await _client.updateProfile(
        request,
        accessToken: accessToken,
      );
      return _userDtoToModel(response.user);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Преобразование UserDto в User модель
  User _userDtoToModel(UserDto dto) {
    final userMetadata = dto.userMetadata ?? {};
    final displayName = userMetadata['display_name'] as String?;
    final phoneNumber = dto.phone ?? userMetadata['phone_number'] as String?;
    final photoUrl = dto.avatarUrl ?? userMetadata['photo_url'] as String?;

    return User(
      id: dto.id,
      email: dto.email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      createdAt: DateTime.parse(dto.createdAt),
      isEmailVerified: dto.emailConfirmedAt != null,
      currency: Currency.rub, // По умолчанию, можно расширить
      themeMode: ThemeMode.system, // По умолчанию, можно расширить
      notificationsEnabled: true, // По умолчанию, можно расширить
      biometricsEnabled: false, // По умолчанию, можно расширить
      language: 'ru', // По умолчанию, можно расширить
    );
  }

  /// Сохранение токенов в безопасное хранилище
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Очистка токенов из безопасного хранилища
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Обработка ошибок
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }

    if (error is Exception) {
      return UnknownException(
        error.toString(),
        originalError: error,
      );
    }

    return UnknownException(
      'Произошла неизвестная ошибка',
      originalError: error,
    );
  }
}

