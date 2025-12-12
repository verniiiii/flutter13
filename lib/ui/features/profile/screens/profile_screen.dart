import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/auth/state/auth_store.dart';
import 'package:prac13/core/models/user_model.dart' as model;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Показываем toast при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authStore = GetIt.I<AuthStore>();
      if (authStore.currentUser != null && mounted) {
        final userName = authStore.currentUser!.displayName ?? 
                        authStore.currentUser!.email.split('@').first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Добро пожаловать, $userName!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStore = GetIt.I<AuthStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль и настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (authStore.currentUser == null) {
            return _buildNotLoggedInState(context);
          }

          return _buildProfileContent(authStore, context);
        },
      ),
    );
  }

  Widget _buildNotLoggedInState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Вы не авторизованы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Войдите в аккаунт для доступа к настройкам',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.push('/login');
            },
            child: const Text('Войти в аккаунт'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(AuthStore authStore, BuildContext context) {
    final user = authStore.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок профиля
          _buildProfileHeader(user, context),

          const SizedBox(height: 24),

          // Настройки приложения
          _buildAppSettingsSection(authStore, context),

          const SizedBox(height: 24),

          // Безопасность
          _buildSecuritySection(authStore, context),

          const SizedBox(height: 24),

          // О приложении
          _buildAboutSection(context),

          const SizedBox(height: 24),

          // Выход
          _buildLogoutSection(authStore, context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(model.User user, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватар
            GestureDetector(
              onTap: () {
                context.push('/edit-profile');
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Имя и email
            Text(
              user.displayName ?? 'Пользователь',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            if (user.phoneNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                user.phoneNumber!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Кнопка редактирования
            OutlinedButton(
              onPressed: () {
                context.push('/edit-profile');
              },
              child: const Text('Редактировать профиль'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(AuthStore authStore, BuildContext context) {
    return Observer(
      builder: (_) {
        final user = authStore.currentUser!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Настройки приложения',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Валюта
                _buildSettingItem(
                  icon: Icons.currency_ruble,
                  title: 'Валюта',
                  value: user.currency.displayName,
                  onTap: () => _showCurrencyDialog(authStore, context),
                ),

                const Divider(),

                // Тема
                _buildSettingItem(
                  icon: Icons.palette,
                  title: 'Тема оформления',
                  value: user.themeMode.displayName,
                  onTap: () => _showThemeDialog(authStore, context),
                ),

                const Divider(),

                // Язык
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'Язык',
                  value: 'Русский',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Смена языка будет доступна в следующем обновлении')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecuritySection(AuthStore authStore, BuildContext context) {
    return Observer(
      builder: (_) {
        final user = authStore.currentUser!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Безопасность',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Уведомления
                _buildSwitchSetting(
                  icon: Icons.notifications,
                  title: 'Push-уведомления',
                  value: user.notificationsEnabled,
                  onChanged: (value) {
                    authStore.updateSettings(notificationsEnabled: value);
                  },
                ),

                const Divider(),

                // Биометрия
                _buildSwitchSetting(
                  icon: Icons.fingerprint,
                  title: 'Вход по отпечатку',
                  value: user.biometricsEnabled,
                  onChanged: (value) {
                    authStore.updateSettings(biometricsEnabled: value);
                  },
                ),

                const Divider(),

                // Смена пароля
                _buildSettingItem(
                  icon: Icons.lock,
                  title: 'Сменить пароль',
                  value: '',
                  onTap: () {
                    context.push('/change-password');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'О приложении',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingItem(
              icon: Icons.info,
              title: 'Версия',
              value: '1.0.0',
              onTap: () {},
            ),

            const Divider(),

            _buildSettingItem(
              icon: Icons.star,
              title: 'Оценить приложение',
              value: '',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Переход в магазин приложений')),
                );
              },
            ),

            const Divider(),

            _buildSettingItem(
              icon: Icons.share,
              title: 'Поделиться приложением',
              value: '',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Поделиться ссылкой на приложение')),
                );
              },
            ),

            const Divider(),

            _buildSettingItem(
              icon: Icons.help,
              title: 'Помощь и поддержка',
              value: '',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Переход в раздел помощи')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(AuthStore authStore, BuildContext context) {
    return Observer(
      builder: (_) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: authStore.isLoading ? null : () => _showLogoutDialog(authStore, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: authStore.isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Выйти из аккаунта',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSetting({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showCurrencyDialog(AuthStore authStore, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Observer(
        builder: (_) {
          final currentCurrency = authStore.currentUser!.currency;
          return AlertDialog(
            title: const Text('Выберите валюту'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: model.Currency.values.map((currency) {
                return RadioListTile<model.Currency>(
                  value: currency,
                  groupValue: currentCurrency,
                  title: Text(currency.displayName),
                  onChanged: (model.Currency? value) {
                    if (value != null) {
                      authStore.updateSettings(currency: value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showThemeDialog(AuthStore authStore, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Observer(
        builder: (_) {
          final currentTheme = authStore.currentUser!.themeMode;
          return AlertDialog(
            title: const Text('Выберите тему'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: model.ThemeMode.values.map((theme) {
                return RadioListTile<model.ThemeMode>(
                  value: theme,
                  groupValue: currentTheme,
                  title: Text(theme.displayName),
                  onChanged: (model.ThemeMode? value) {
                    if (value != null) {
                      authStore.updateSettings(themeMode: value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(AuthStore authStore, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти? Все данные будут сохранены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authStore.logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}