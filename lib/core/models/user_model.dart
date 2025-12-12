enum Currency {
  rub('Рубли (₽)', 'RUB'),
  usd('Доллары (\$)', 'USD'),
  eur('Евро (€)', 'EUR');

  const Currency(this.displayName, this.symbol);
  final String displayName;
  final String symbol;
}

enum ThemeMode {
  light('Светлая'),
  dark('Тёмная'),
  system('Как в системе');

  const ThemeMode(this.displayName);
  final String displayName;
}

class User {
  final String id;
  String email;
  String? displayName;
  String? phoneNumber;
  String? photoUrl;
  DateTime createdAt;
  bool isEmailVerified;
  Currency currency;
  ThemeMode themeMode;
  bool notificationsEnabled;
  bool biometricsEnabled;
  String? language;

  User({
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

  String get currencySymbol => currency.symbol;
  String get currencyDisplayName => currency.displayName;
  String get themeModeDisplayName => themeMode.displayName;

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
    String? language,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      language: language ?? this.language,
    );
  }
}