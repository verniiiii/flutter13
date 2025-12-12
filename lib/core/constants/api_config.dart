/// Конфигурация API
class ApiConfig {
  /// Базовый URL для Supabase Auth API
  /// Формат: https://your-project-id.supabase.co/auth/v1
  static const String supabaseAuthBaseUrl = 'https://ukxklittlygfzecacfkw.supabase.co/auth/v1';

  /// API ключ для Supabase Auth (publishable key)
  static const String supabaseApiKey = 'sb_publishable_xEPYT_auM1eBvDReFy5bnQ_Sgc9xou5';

  /// API ключ для NewsAPI.org
  /// TODO: Получите бесплатный API ключ на https://newsapi.org/register
  /// Бесплатный тариф: 100 запросов/день
  static const String newsApiKey = '0e6ae88af40c479f813c691826b0038f';

  /// Получить базовый URL для Supabase Auth
  static String getSupabaseAuthBaseUrl() {
    return supabaseAuthBaseUrl;
  }

  /// Получить API ключ для Supabase Auth
  static String getSupabaseApiKey() {
    return supabaseApiKey;
  }

  /// Получить API ключ для NewsAPI
  static String getNewsApiKey() {
    return newsApiKey;
  }
}
