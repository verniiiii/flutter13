import '../entities/user_entity.dart';
import 'package:prac13/core/models/user_model.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String email, String password, String confirmPassword);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  });
  Future<UserEntity> updateSettings({
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
    String? language,
  });
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String oldPassword, String newPassword);
}
