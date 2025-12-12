import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'core/service_locator.dart';
import 'app_router.dart';
import 'ui/features/auth/state/auth_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем Service Locator
  await setupServiceLocator();

  // Загружаем текущего пользователя при старте приложения
  final authStore = GetIt.I<AuthStore>();
  await authStore.loadCurrentUser();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Financial Tracker',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}