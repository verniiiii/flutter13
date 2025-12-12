import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

/// DTO для запроса регистрации
@JsonSerializable()
class SignUpRequestDto {
  final String email;
  final String password;
  @JsonKey(name: 'data')
  final Map<String, dynamic>? userMetadata;

  SignUpRequestDto({
    required this.email,
    required this.password,
    this.userMetadata,
  });

  factory SignUpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpRequestDtoToJson(this);
}

/// DTO для запроса входа
@JsonSerializable()
class SignInRequestDto {
  final String email;
  final String password;

  SignInRequestDto({
    required this.email,
    required this.password,
  });

  factory SignInRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignInRequestDtoToJson(this);
}

/// DTO для запроса обновления токена
@JsonSerializable()
class RefreshTokenRequestDto {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  RefreshTokenRequestDto({
    required this.refreshToken,
  });

  factory RefreshTokenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestDtoToJson(this);
}

/// DTO для ответа аутентификации
@JsonSerializable()
class AuthResponseDto {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final UserDto? user;

  AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);
}

/// DTO для ответа обновления токена
@JsonSerializable()
class RefreshTokenResponseDto {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  @JsonKey(name: 'token_type')
  final String tokenType;

  RefreshTokenResponseDto({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseDtoToJson(this);
}

/// DTO для пользователя
@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  @JsonKey(name: 'user_metadata')
  final Map<String, dynamic>? userMetadata;
  @JsonKey(name: 'app_metadata')
  final Map<String, dynamic>? appMetadata;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'email_confirmed_at')
  final String? emailConfirmedAt;
  @JsonKey(name: 'phone')
  final String? phone;
  @JsonKey(name: 'phone_confirmed_at')
  final String? phoneConfirmedAt;
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'last_sign_in_at')
  final String? lastSignInAt;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  UserDto({
    required this.id,
    required this.email,
    this.userMetadata,
    this.appMetadata,
    required this.createdAt,
    this.updatedAt,
    this.emailConfirmedAt,
    this.phone,
    this.phoneConfirmedAt,
    this.confirmedAt,
    this.lastSignInAt,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

/// DTO для ответа получения пользователя
@JsonSerializable()
class UserResponseDto {
  final UserDto user;

  UserResponseDto({
    required this.user,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDtoToJson(this);
}

/// DTO для запроса обновления пароля
@JsonSerializable()
class UpdatePasswordRequestDto {
  final String password;

  UpdatePasswordRequestDto({
    required this.password,
  });

  factory UpdatePasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePasswordRequestDtoToJson(this);
}

/// DTO для запроса обновления профиля
@JsonSerializable()
class UpdateProfileRequestDto {
  @JsonKey(name: 'user_metadata')
  final Map<String, dynamic>? userMetadata;

  UpdateProfileRequestDto({
    this.userMetadata,
  });

  factory UpdateProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestDtoToJson(this);
}

