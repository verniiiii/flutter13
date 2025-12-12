import '../../datasources/remote/dto/auth_dto.dart';
import '../../../core/models/user_model.dart';
import '../../../domain/entities/user_entity.dart';

/// Маппер для преобразования DTO в доменные сущности и модели
class AuthMapper {
  /// Преобразование UserDto в UserEntity
  static UserEntity userDtoToEntity(UserDto dto) {
    final userMetadata = dto.userMetadata ?? {};
    final displayName = userMetadata['display_name'] as String?;
    final phoneNumber = dto.phone ?? userMetadata['phone_number'] as String?;
    final photoUrl = dto.avatarUrl ?? userMetadata['photo_url'] as String?;

    return UserEntity(
      id: dto.id,
      email: dto.email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      createdAt: DateTime.parse(dto.createdAt),
      isEmailVerified: dto.emailConfirmedAt != null,
      currency: Currency.rub,
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      biometricsEnabled: false,
      language: 'ru',
    );
  }

  /// Преобразование UserDto в User модель
  static User userDtoToModel(UserDto dto) {
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
      currency: Currency.rub,
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      biometricsEnabled: false,
      language: 'ru',
    );
  }

  /// Преобразование User модели в UserEntity
  static UserEntity modelToEntity(User model) {
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
}

