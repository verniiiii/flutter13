// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpRequestDto _$SignUpRequestDtoFromJson(Map<String, dynamic> json) =>
    SignUpRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      userMetadata: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SignUpRequestDtoToJson(SignUpRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'data': instance.userMetadata,
    };

SignInRequestDto _$SignInRequestDtoFromJson(Map<String, dynamic> json) =>
    SignInRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignInRequestDtoToJson(SignInRequestDto instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RefreshTokenRequestDto _$RefreshTokenRequestDtoFromJson(
  Map<String, dynamic> json,
) => RefreshTokenRequestDto(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenRequestDtoToJson(
  RefreshTokenRequestDto instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      tokenType: json['token_type'] as String,
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseDtoToJson(AuthResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
      'user': instance.user,
    };

RefreshTokenResponseDto _$RefreshTokenResponseDtoFromJson(
  Map<String, dynamic> json,
) => RefreshTokenResponseDto(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String?,
  expiresIn: (json['expires_in'] as num).toInt(),
  tokenType: json['token_type'] as String,
);

Map<String, dynamic> _$RefreshTokenResponseDtoToJson(
  RefreshTokenResponseDto instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'expires_in': instance.expiresIn,
  'token_type': instance.tokenType,
};

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
  userMetadata: json['user_metadata'] as Map<String, dynamic>?,
  appMetadata: json['app_metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
  emailConfirmedAt: json['email_confirmed_at'] as String?,
  phone: json['phone'] as String?,
  phoneConfirmedAt: json['phone_confirmed_at'] as String?,
  confirmedAt: json['confirmed_at'] as String?,
  lastSignInAt: json['last_sign_in_at'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'user_metadata': instance.userMetadata,
  'app_metadata': instance.appMetadata,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'email_confirmed_at': instance.emailConfirmedAt,
  'phone': instance.phone,
  'phone_confirmed_at': instance.phoneConfirmedAt,
  'confirmed_at': instance.confirmedAt,
  'last_sign_in_at': instance.lastSignInAt,
  'avatar_url': instance.avatarUrl,
};

UserResponseDto _$UserResponseDtoFromJson(Map<String, dynamic> json) =>
    UserResponseDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserResponseDtoToJson(UserResponseDto instance) =>
    <String, dynamic>{'user': instance.user};

UpdatePasswordRequestDto _$UpdatePasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdatePasswordRequestDto(password: json['password'] as String);

Map<String, dynamic> _$UpdatePasswordRequestDtoToJson(
  UpdatePasswordRequestDto instance,
) => <String, dynamic>{'password': instance.password};

UpdateProfileRequestDto _$UpdateProfileRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequestDto(
  userMetadata: json['user_metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UpdateProfileRequestDtoToJson(
  UpdateProfileRequestDto instance,
) => <String, dynamic>{'user_metadata': instance.userMetadata};
