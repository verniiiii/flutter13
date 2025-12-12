import 'package:shared_preferences/shared_preferences.dart';
import 'package:prac13/core/models/user_model.dart';

class SettingsLocalDataSource {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyCurrency = 'currency';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyBiometricsEnabled = 'biometrics_enabled';

  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  // Theme Mode
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_keyThemeMode, _themeModeToString(themeMode));
  }

  ThemeMode? getThemeMode() {
    final value = _prefs.getString(_keyThemeMode);
    if (value == null) return null;
    return _stringToThemeMode(value);
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(_keyLanguage, language);
  }

  String? getLanguage() {
    return _prefs.getString(_keyLanguage);
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Currency
  Future<void> saveCurrency(Currency currency) async {
    await _prefs.setString(_keyCurrency, _currencyToString(currency));
  }

  Currency? getCurrency() {
    final value = _prefs.getString(_keyCurrency);
    if (value == null) return null;
    return _stringToCurrency(value);
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  bool isNotificationsEnabled() {
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // Biometrics
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricsEnabled, enabled);
  }

  bool isBiometricsEnabled() {
    return _prefs.getBool(_keyBiometricsEnabled) ?? false;
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _prefs.remove(_keyThemeMode);
    await _prefs.remove(_keyLanguage);
    await _prefs.remove(_keyOnboardingCompleted);
    await _prefs.remove(_keyCurrency);
    await _prefs.remove(_keyNotificationsEnabled);
    await _prefs.remove(_keyBiometricsEnabled);
  }

  // Helper methods
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  String _currencyToString(Currency currency) {
    switch (currency) {
      case Currency.rub:
        return 'rub';
      case Currency.usd:
        return 'usd';
      case Currency.eur:
        return 'eur';
    }
  }

  Currency _stringToCurrency(String str) {
    switch (str) {
      case 'rub':
        return Currency.rub;
      case 'usd':
        return Currency.usd;
      case 'eur':
        return Currency.eur;
      default:
        return Currency.rub;
    }
  }
}

