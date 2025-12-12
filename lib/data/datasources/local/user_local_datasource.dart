import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prac13/core/models/user_model.dart';

class UserLocalDataSource {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPassword = 'user_password';
  static const String _keyDisplayName = 'display_name';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyPhotoUrl = 'photo_url';
  static const String _keyIsEmailVerified = 'is_email_verified';

  final FlutterSecureStorage _storage;

  UserLocalDataSource(this._storage);

  // Tokens
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // User Email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  // User Password (encrypted)
  Future<void> saveUserPassword(String password) async {
    await _storage.write(key: _keyUserPassword, value: password);
  }

  Future<String?> getUserPassword() async {
    return await _storage.read(key: _keyUserPassword);
  }

  // Display Name
  Future<void> saveDisplayName(String? displayName) async {
    if (displayName != null) {
      await _storage.write(key: _keyDisplayName, value: displayName);
    } else {
      await _storage.delete(key: _keyDisplayName);
    }
  }

  Future<String?> getDisplayName() async {
    return await _storage.read(key: _keyDisplayName);
  }

  // Phone Number
  Future<void> savePhoneNumber(String? phoneNumber) async {
    if (phoneNumber != null) {
      await _storage.write(key: _keyPhoneNumber, value: phoneNumber);
    } else {
      await _storage.delete(key: _keyPhoneNumber);
    }
  }

  Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _keyPhoneNumber);
  }

  // Photo URL
  Future<void> savePhotoUrl(String? photoUrl) async {
    if (photoUrl != null) {
      await _storage.write(key: _keyPhotoUrl, value: photoUrl);
    } else {
      await _storage.delete(key: _keyPhotoUrl);
    }
  }

  Future<String?> getPhotoUrl() async {
    return await _storage.read(key: _keyPhotoUrl);
  }

  // Email Verified
  Future<void> saveIsEmailVerified(bool isVerified) async {
    await _storage.write(key: _keyIsEmailVerified, value: isVerified.toString());
  }

  Future<bool> isEmailVerified() async {
    final value = await _storage.read(key: _keyIsEmailVerified);
    return value == 'true';
  }

  // Save full user data
  Future<void> saveUserData(User user) async {
    await Future.wait([
      saveUserId(user.id),
      saveUserEmail(user.email),
      saveDisplayName(user.displayName),
      savePhoneNumber(user.phoneNumber),
      savePhotoUrl(user.photoUrl),
      saveIsEmailVerified(user.isEmailVerified),
    ]);
  }

  // Get full user data
  Future<User?> getUserData() async {
    final userId = await getUserId();
    final email = await getUserEmail();

    if (userId == null || email == null) return null;

    final displayName = await getDisplayName();
    final phoneNumber = await getPhoneNumber();
    final photoUrl = await getPhotoUrl();
    final isEmailVerified = await this.isEmailVerified();

    return User(
      id: userId,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      createdAt: DateTime.now(), // Note: createdAt should be stored separately if needed
      isEmailVerified: isEmailVerified,
    );
  }

  // Clear all user data
  Future<void> clearAllUserData() async {
    await _storage.deleteAll();
  }
}

