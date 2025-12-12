import 'package:prac13/core/models/user_model.dart';

class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  final Currency currency;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool biometricsEnabled;
  final String? language;

  UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.isEmailVerified = false,
    this.currency = Currency.rub,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.biometricsEnabled = false,
    this.language,
  });
}

