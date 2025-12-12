import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/transactions/screens/transactions_list_screen.dart';
import 'package:prac13/ui/features/transactions/screens/statistics_screen.dart';
import 'package:prac13/ui/features/transactions/screens/transaction_details_screen.dart';
import 'package:prac13/ui/features/profile/screens/profile_screen.dart';
import 'package:prac13/ui/features/transactions/screens/transaction_form_screen.dart';
import 'package:prac13/ui/features/transactions/screens/edit_transaction_screen.dart';
import 'package:prac13/core/models/models.dart';
import 'package:prac13/ui/features/onboarding/screens/onboarding_screen.dart';
import 'package:prac13/ui/features/auth/screens/login_screen.dart';
import 'package:prac13/ui/features/auth/screens/register_screen.dart';
import 'package:prac13/ui/features/cards/screens/card_form_screen.dart';
import 'package:prac13/ui/features/cards/screens/cards_list_screen.dart';
import 'package:prac13/ui/features/cards/state/cards_store.dart';
import 'package:prac13/ui/features/profile/screens/edit_profile_screen.dart';
import 'package:prac13/ui/features/calculator/screens/calculator_screen.dart';
import 'package:prac13/ui/features/motivation/screens/motivation_screen.dart';
import 'package:prac13/ui/features/social/screens/friends_screen.dart';
import 'package:prac13/ui/features/news/screens/news_screen.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      // Маршруты для карт (вынесены на верхний уровень)
      GoRoute(
        path: '/cards',
        builder: (BuildContext context, GoRouterState state) {
          return const CardsListScreen();
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (BuildContext context, GoRouterState state) {
              return const CardFormScreen();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              // TODO: Создать экран деталей карты
              return const CardsListScreen();
            },
          ),
          GoRoute(
            path: ':id/edit',
            builder: (BuildContext context, GoRouterState state) {
              final store = GetIt.I<CardsStore>();
              final cardId = state.pathParameters['id'] ?? '';
              final card = store.getCardById(cardId);
              return CardFormScreen(card: card);
            },
          ),
        ],
      ),
      // Основной маршрут с транзакциями
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const TransactionsListScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'statistics',
            builder: (BuildContext context, GoRouterState state) {
              return const StatisticsScreen();
            },
          ),
          GoRoute(
            path: 'details',
            builder: (BuildContext context, GoRouterState state) {
              final transactionId = state.pathParameters['id'] ?? '';
              return TransactionDetailsScreen(transactionId: transactionId);
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (BuildContext context, GoRouterState state) {
              return const EditProfileScreen();
            },
          ),
          GoRoute(
            path: 'add',
            builder: (BuildContext context, GoRouterState state) {
              return TransactionFormScreen(
                onSave: (transaction) {
                  // Обработка сохранения транзакции
                },
              );
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id'] ?? '';
              final transaction = state.extra as Transaction?;
              return EditTransactionScreen(
                transaction: transaction!,
                onUpdate: (updatedTransaction) {
                  // Обработка обновления транзакции
                },
              );
            },
          ),
          // Маршрут для калькулятора
          GoRoute(
            path: '/calculator',
            builder: (BuildContext context, GoRouterState state) {
              return const CalculatorScreen();
            },
          ),
          GoRoute(
            path: '/motivation',
            builder: (BuildContext context, GoRouterState state) {
              return const MotivationScreen();
            },
          ),
          GoRoute(
            path: '/friends',
            builder: (BuildContext context, GoRouterState state) {
              return const FriendsScreen();
            },
          ),
          GoRoute(
            path: '/news',
            builder: (BuildContext context, GoRouterState state) {
              return const NewsScreen();
            },
          ),
        ],
      ),
    ],
  );
}