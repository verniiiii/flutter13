import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core Models
import 'package:prac13/core/models/transaction_model.dart';

// All Local Data Sources (from local/ folder)
import 'package:prac13/data/datasources/local/app_database.dart';
import 'package:prac13/data/datasources/local/transaction_local_datasource.dart';
import 'package:prac13/data/datasources/local/card_local_datasource.dart';
import 'package:prac13/data/datasources/local/motivation_local_datasource.dart';
import 'package:prac13/data/datasources/local/news_local_datasource.dart';
import 'package:prac13/data/datasources/local/settings_local_datasource.dart';
import 'package:prac13/data/datasources/local/user_local_datasource.dart';
import 'package:prac13/data/datasources/local/auth_local_datasource.dart';
import 'package:prac13/data/datasources/local/social_local_datasource.dart';

// Remote Data Sources
import 'package:prac13/data/datasources/remote/api/dio_client.dart';
import 'package:prac13/data/datasources/remote/api/supabase_auth_client.dart';
import 'package:prac13/data/datasources/remote/auth_remote_datasource.dart';
import 'package:prac13/data/datasources/remote/api/news_api_client.dart';
import 'package:prac13/data/datasources/remote/news_remote_datasource.dart';

// Core Constants
import 'package:prac13/core/constants/api_config.dart';

// Repositories
import 'package:prac13/data/repositories/transaction_repository_impl.dart';
import 'package:prac13/data/repositories/auth_repository_impl.dart';
import 'package:prac13/data/repositories/card_repository_impl.dart';
import 'package:prac13/data/repositories/news_repository_impl.dart';
import 'package:prac13/data/repositories/motivation_repository_impl.dart';
import 'package:prac13/data/repositories/social_repository_impl.dart';

// Domain Repositories (interfaces)
import 'package:prac13/domain/repositories/transaction_repository.dart';
import 'package:prac13/domain/repositories/auth_repository.dart';
import 'package:prac13/domain/repositories/card_repository.dart';
import 'package:prac13/domain/repositories/news_repository.dart';
import 'package:prac13/domain/repositories/motivation_repository.dart';
import 'package:prac13/domain/repositories/social_repository.dart';

// Use Cases
import 'package:prac13/domain/usecases/transactions/get_transactions_usecase.dart';
import 'package:prac13/domain/usecases/transactions/add_transaction_usecase.dart';
import 'package:prac13/domain/usecases/transactions/update_transaction_usecase.dart';
import 'package:prac13/domain/usecases/transactions/delete_transaction_usecase.dart';
import 'package:prac13/domain/usecases/transactions/get_transactions_by_type_usecase.dart';
import 'package:prac13/domain/usecases/auth/login_usecase.dart';
import 'package:prac13/domain/usecases/auth/register_usecase.dart';
import 'package:prac13/domain/usecases/auth/logout_usecase.dart';
import 'package:prac13/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:prac13/domain/usecases/cards/get_cards_usecase.dart';
import 'package:prac13/domain/usecases/cards/add_card_usecase.dart';
import 'package:prac13/domain/usecases/cards/delete_card_usecase.dart';
import 'package:prac13/domain/usecases/news/get_news_usecase.dart';
import 'package:prac13/domain/usecases/news/get_currency_rates_usecase.dart';
import 'package:prac13/domain/usecases/motivation/get_random_motivation_usecase.dart';
import 'package:prac13/domain/usecases/social/get_friends_usecase.dart';

// Presentation Stores
import 'package:prac13/ui/features/transactions/state/transaction_form_store.dart';
import 'package:prac13/ui/features/transactions/state/edit_transaction_store.dart';
import 'package:prac13/ui/features/transactions/state/statistics_store.dart';
import 'package:prac13/ui/features/transactions/state/transaction_details_store.dart';
import 'package:prac13/ui/features/onboarding/state/onboarding_store.dart';
import 'package:prac13/ui/features/auth/state/auth_store.dart';
import 'package:prac13/ui/features/cards/state/cards_store.dart';
import 'package:prac13/ui/features/calculator/state/calculator_store.dart';
import 'package:prac13/ui/features/motivation/state/motivation_store.dart';
import 'package:prac13/ui/features/social/state/social_store.dart';
import 'package:prac13/ui/features/news/state/news_store.dart';

// New Clean Architecture Stores
import 'package:prac13/ui/features/transactions/state/transactions_list_store.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ========== CORE DEPENDENCIES ==========
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Initialize Flutter Secure Storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Initialize AppDatabase (SQLite) - Только вызов статических методов для инициализации
  // AppDatabase не нужно регистрировать как singleton, так как он полностью статический

  // ========== SQLite DATA SOURCES (from local/ folder) ==========
  // These use SQLite for persistent storage
  final transactionSqliteDataSource = TransactionLocalDataSource();
  final cardSqliteDataSource = CardLocalDataSource();
  final motivationSqliteDataSource = MotivationLocalDataSource();
  final newsSqliteDataSource = NewsLocalDataSource();

  // Register as base types for use in repositories
  getIt.registerSingleton<TransactionLocalDataSource>(transactionSqliteDataSource);
  getIt.registerSingleton<CardLocalDataSource>(cardSqliteDataSource);
  getIt.registerSingleton<MotivationLocalDataSource>(motivationSqliteDataSource);
  getIt.registerSingleton<NewsLocalDataSource>(newsSqliteDataSource);

  // SharedPreferences Data Source
  final settingsLocalDataSource = SettingsLocalDataSource(sharedPreferences);
  getIt.registerSingleton<SettingsLocalDataSource>(settingsLocalDataSource);

  // Flutter Secure Storage Data Source
  final userLocalDataSource = UserLocalDataSource(secureStorage);
  getIt.registerSingleton<UserLocalDataSource>(userLocalDataSource);

  // ========== DATA SOURCES FOR REPOSITORIES (from local/ folder) ==========
  // Using the same SQLite instances registered above
  final transactionLocalDataSource = transactionSqliteDataSource;
  final cardLocalDataSource = cardSqliteDataSource;
  final newsLocalDataSource = newsSqliteDataSource;
  final motivationLocalDataSource = motivationSqliteDataSource;
  
  // Other data sources
  final authLocalDataSource = AuthLocalDataSource();
  final socialLocalDataSource = SocialLocalDataSource();

  getIt.registerSingleton<AuthLocalDataSource>(authLocalDataSource);
  getIt.registerSingleton<SocialLocalDataSource>(socialLocalDataSource);

  // Initialize mock state for data sources that need it
  // Note: SQLite-based sources don't need initializeMockData, but social still does
  socialLocalDataSource.initializeMockData();

  // ========== REMOTE DATA SOURCES ==========
  // Supabase Auth API Configuration
  final supabaseBaseUrl = ApiConfig.getSupabaseAuthBaseUrl();
  final supabaseApiKey = ApiConfig.getSupabaseApiKey();
  
  // Supabase Auth Client (чистый Dio, без Retrofit)
  final supabaseAuthClient = SupabaseAuthClient(
    baseUrl: supabaseBaseUrl,
    apiKey: supabaseApiKey,
  );
  getIt.registerSingleton<SupabaseAuthClient>(supabaseAuthClient);

  // Auth Remote DataSource
  final authRemoteDataSource = AuthRemoteDataSource(
    client: supabaseAuthClient,
    secureStorage: secureStorage,
  );
  getIt.registerSingleton<AuthRemoteDataSource>(authRemoteDataSource);

  // NewsAPI.org Client (чистый Dio, без Retrofit)
  final newsApiKey = ApiConfig.getNewsApiKey();
  final newsApiClient = NewsApiClient(apiKey: newsApiKey);
  getIt.registerSingleton<NewsApiClient>(newsApiClient);

  // News Remote DataSource
  final newsRemoteDataSource = NewsRemoteDataSource(
    apiClient: newsApiClient,
  );
  getIt.registerSingleton<NewsRemoteDataSource>(newsRemoteDataSource);

  // ========== REPOSITORIES ==========
  final transactionRepository = TransactionRepositoryImpl(transactionLocalDataSource);
  final authRepository = AuthRepositoryImpl(
    authLocalDataSource,
    remoteDataSource: authRemoteDataSource,
  );
  final cardRepository = CardRepositoryImpl(cardLocalDataSource);
  final newsRepository = NewsRepositoryImpl(
    newsLocalDataSource,
    remoteDataSource: newsRemoteDataSource,
  );
  final motivationRepository = MotivationRepositoryImpl(motivationLocalDataSource);
  final socialRepository = SocialRepositoryImpl(socialLocalDataSource);

  getIt.registerSingleton<TransactionRepository>(transactionRepository);
  getIt.registerSingleton<AuthRepository>(authRepository);
  getIt.registerSingleton<CardRepository>(cardRepository);
  getIt.registerSingleton<NewsRepository>(newsRepository);
  getIt.registerSingleton<MotivationRepository>(motivationRepository);
  getIt.registerSingleton<SocialRepository>(socialRepository);

  // ========== USE CASES ==========
  // Transactions
  getIt.registerLazySingleton<GetTransactionsUseCase>(
        () => GetTransactionsUseCase(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<AddTransactionUseCase>(
        () => AddTransactionUseCase(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<UpdateTransactionUseCase>(
        () => UpdateTransactionUseCase(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<DeleteTransactionUseCase>(
        () => DeleteTransactionUseCase(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<GetTransactionsByTypeUseCase>(
        () => GetTransactionsByTypeUseCase(getIt<TransactionRepository>()),
  );

  // Auth
  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  // Cards
  getIt.registerLazySingleton<GetCardsUseCase>(
        () => GetCardsUseCase(getIt<CardRepository>()),
  );
  getIt.registerLazySingleton<AddCardUseCase>(
        () => AddCardUseCase(getIt<CardRepository>()),
  );
  getIt.registerLazySingleton<DeleteCardUseCase>(
        () => DeleteCardUseCase(getIt<CardRepository>()),
  );

  // News
  getIt.registerLazySingleton<GetNewsUseCase>(
        () => GetNewsUseCase(getIt<NewsRepository>()),
  );
  getIt.registerLazySingleton<GetCurrencyRatesUseCase>(
        () => GetCurrencyRatesUseCase(getIt<NewsRepository>()),
  );

  // Motivation
  getIt.registerLazySingleton<GetRandomMotivationUseCase>(
        () => GetRandomMotivationUseCase(getIt<MotivationRepository>()),
  );

  // Social
  getIt.registerLazySingleton<GetFriendsUseCase>(
        () => GetFriendsUseCase(getIt<SocialRepository>()),
  );

  // ========== PRESENTATION STORES ==========
  // Clean Architecture Stores - теперь без параметров
  getIt.registerLazySingleton<TransactionsListStore>(
        () => TransactionsListStore(),
  );

  // Legacy Stores (keeping for backward compatibility)
  getIt.registerLazySingleton<TransactionFormStore>(() => TransactionFormStore());
  getIt.registerLazySingleton<EditTransactionStore>(() => EditTransactionStore());
  getIt.registerLazySingleton<StatisticsStore>(() => StatisticsStore());
  getIt.registerLazySingleton<TransactionDetailsStore>(() => TransactionDetailsStore());
  getIt.registerLazySingleton<OnboardingStore>(() => OnboardingStore());
  getIt.registerLazySingleton<AuthStore>(() => AuthStore());
  getIt.registerLazySingleton<CardsStore>(() => CardsStore());
  getIt.registerLazySingleton<CalculatorStore>(() => CalculatorStore());
  getIt.registerLazySingleton<MotivationStore>(() => MotivationStore());
  getIt.registerLazySingleton<SocialStore>(() => SocialStore());
  getIt.registerLazySingleton<NewsStore>(() => NewsStore());

  // Убираем ObservableList так как мы больше не используем MobX
  // getIt.registerSingleton<ObservableList<Transaction>>(ObservableList<Transaction>());
}