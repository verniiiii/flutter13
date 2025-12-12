import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/auth_dto.dart';

part 'supabase_auth_api.g.dart';

@RestApi(baseUrl: 'https://your-project.supabase.co/auth/v1')
abstract class SupabaseAuthApi {
  factory SupabaseAuthApi(Dio dio, {String? baseUrl}) = _SupabaseAuthApi;

  /// Регистрация нового пользователя
  @POST('/signup')
  Future<AuthResponseDto> signUp(@Body() SignUpRequestDto request);

  /// Вход пользователя
  @POST('/token')
  Future<AuthResponseDto> signIn(
    @Body() SignInRequestDto request,
    @Query('grant_type') String grantType,
  );

  /// Получение данных текущего пользователя
  @GET('/user')
  Future<UserResponseDto> getUser();

  /// Обновление токена доступа
  @POST('/token')
  Future<RefreshTokenResponseDto> refreshToken(
    @Body() RefreshTokenRequestDto request,
    @Query('grant_type') String grantType,
  );

  /// Выход пользователя
  @POST('/logout')
  Future<void> logout();

  /// Обновление пароля пользователя
  @PUT('/user')
  Future<UserResponseDto> updatePassword(@Body() UpdatePasswordRequestDto request);

  /// Обновление профиля пользователя
  @PUT('/user')
  Future<UserResponseDto> updateProfile(@Body() UpdateProfileRequestDto request);
}

