import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/core/models/news_model.dart';
import 'package:prac13/domain/usecases/news/get_news_usecase.dart';
import 'package:prac13/domain/usecases/news/get_top_headlines_usecase.dart';
import 'package:prac13/domain/usecases/news/search_news_usecase.dart';
import 'package:prac13/domain/usecases/news/get_news_by_category_usecase.dart';
import 'package:prac13/domain/usecases/news/mark_as_read_usecase.dart';
import 'package:prac13/domain/entities/news_entity.dart';
import 'package:prac13/data/datasources/remote/api/exceptions.dart';

class NewsStore with ChangeNotifier {
  final GetNewsUseCase _getNewsUseCase;
  final GetTopHeadlinesUseCase _getTopHeadlinesUseCase;
  final SearchNewsUseCase _searchNewsUseCase;
  final GetNewsByCategoryUseCase _getNewsByCategoryUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;

  List<NewsArticle> _newsArticles = [];
  List<CurrencyRate> _currencyRates = [];
  bool _isLoading = false;
  String _errorMessage = '';
  NewsCategory _selectedCategory = NewsCategory.finance;
  String _searchQuery = '';
  bool _showOnlyUnread = false;
  String? _selectedCountry;
  List<String>? _selectedSources;

  List<NewsArticle> get newsArticles => List.unmodifiable(_newsArticles);
  List<CurrencyRate> get currencyRates => List.unmodifiable(_currencyRates);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  NewsCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get showOnlyUnread => _showOnlyUnread;
  bool get hasError => _errorMessage.isNotEmpty;

  List<NewsArticle> get filteredNews {
    // Если есть поисковый запрос, фильтруем локально (так как поиск уже выполнен через API)
    var articles = List<NewsArticle>.from(_newsArticles);

    // Фильтруем по категории только если нет поискового запроса
    // (при поиске API уже вернул релевантные результаты)
    if (_searchQuery.isEmpty) {
      articles = articles.where((article) =>
          article.category == _selectedCategory).toList();
    }

    // Дополнительная локальная фильтрация по поисковому запросу (если нужно)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      articles = articles.where((article) =>
          article.title.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query)).toList();
    }

    if (_showOnlyUnread) {
      articles = articles.where((article) => !article.isRead).toList();
    }

    // Сортируем по дате (сначала новые)
    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return articles;
  }

  List<CurrencyRate> get majorCurrencies => _currencyRates
      .where((currency) =>
  currency.code == 'USD' ||
      currency.code == 'EUR' ||
      currency.code == 'GBP' ||
      currency.code == 'CNY')
      .toList();

  List<CurrencyRate> get otherCurrencies => _currencyRates
      .where((currency) =>
  currency.code != 'USD' &&
      currency.code != 'EUR' &&
      currency.code != 'GBP' &&
      currency.code != 'CNY')
      .toList();

  NewsStore({
    GetNewsUseCase? getNewsUseCase,
    GetTopHeadlinesUseCase? getTopHeadlinesUseCase,
    SearchNewsUseCase? searchNewsUseCase,
    GetNewsByCategoryUseCase? getNewsByCategoryUseCase,
    MarkAsReadUseCase? markAsReadUseCase,
  })  : _getNewsUseCase = getNewsUseCase ?? GetIt.I<GetNewsUseCase>(),
        _getTopHeadlinesUseCase = getTopHeadlinesUseCase ?? GetIt.I<GetTopHeadlinesUseCase>(),
        _searchNewsUseCase = searchNewsUseCase ?? GetIt.I<SearchNewsUseCase>(),
        _getNewsByCategoryUseCase = getNewsByCategoryUseCase ?? GetIt.I<GetNewsByCategoryUseCase>(),
        _markAsReadUseCase = markAsReadUseCase ?? GetIt.I<MarkAsReadUseCase>() {
    loadNews();
    _loadDemoCurrencyRates();
  }

  Future<void> loadNews({
    String? country,
    String? category, // <-- теперь это String? а не NewsCategory?
    List<String>? sources,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      List<NewsArticleEntity> entities;

      // Если есть поисковый запрос, используем поиск
      if (_searchQuery.isNotEmpty) {
        entities = await _searchNewsUseCase.call(
          query: _searchQuery,
          sources: sources ?? _selectedSources,
          language: 'ru',
          pageSize: 20,
        );
      }
      // Если передана категория как строка, или выбрана категория в UI
      else if (category != null || _selectedCategory != NewsCategory.finance) {
        // Преобразуем строку в NewsCategory если нужно
        final newsCategory = category != null
            ? _stringToNewsCategory(category)
            : _selectedCategory;

        final categoryName = _mapCategoryToApiCategory(newsCategory);
        entities = await _getNewsByCategoryUseCase.call(
          category: categoryName,
          country: country ?? _selectedCountry ?? 'us',
          pageSize: 20,
        );
      }
      // Иначе загружаем топ новости
      else {
        // Используем либо переданную строку категории, либо дефолтную
        final apiCategory = category ?? _mapCategoryToApiCategory(_selectedCategory);
        entities = await _getTopHeadlinesUseCase.call(
          country: country ?? _selectedCountry ?? 'us',
          category: apiCategory,
          sources: sources ?? _selectedSources,
          pageSize: 20,
        );
      }

      _newsArticles = entities.map(_entityToModel).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      // Если ошибка, оставляем существующие новости
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Преобразование строки категории в enum NewsCategory
  NewsCategory _stringToNewsCategory(String? categoryString) {
    if (categoryString == null) return NewsCategory.finance;

    switch (categoryString.toLowerCase()) {
      case 'finance':
      case 'business':
        return NewsCategory.finance;
      case 'economy':
        return NewsCategory.economy;
      case 'personalFinance':
        return NewsCategory.personalFinance;
      case 'crypto':
        return NewsCategory.crypto;
      case 'stocks':
        return NewsCategory.stocks;
      default:
        return NewsCategory.finance;
    }
  }

  /// Загрузка демо-данных для курсов валют (пока нет API)
  Future<void> _loadDemoCurrencyRates() async {
    // Загружаем курсы валют только если их еще нет
    if (_currencyRates.isNotEmpty) return;

    try {
      // Демо данные - курсы валют
      _currencyRates.addAll([
        CurrencyRate(
          code: 'USD',
          name: 'Доллар США',
          rate: 92.45,
          change: 0.75,
          changePercent: 0.82,
          symbol: '\$',
        ),
        CurrencyRate(
          code: 'EUR',
          name: 'Евро',
          rate: 99.80,
          change: -0.32,
          changePercent: -0.32,
          symbol: '€',
        ),
        CurrencyRate(
          code: 'GBP',
          name: 'Фунт стерлингов',
          rate: 115.20,
          change: 1.10,
          changePercent: 0.96,
          symbol: '£',
        ),
        CurrencyRate(
          code: 'CNY',
          name: 'Китайский юань',
          rate: 12.75,
          change: 0.05,
          changePercent: 0.39,
          symbol: '¥',
        ),
        CurrencyRate(
          code: 'JPY',
          name: 'Японская иена',
          rate: 0.62,
          change: -0.01,
          changePercent: -1.59,
          symbol: '¥',
        ),
        CurrencyRate(
          code: 'CHF',
          name: 'Швейцарский франк',
          rate: 102.30,
          change: 0.45,
          changePercent: 0.44,
          symbol: 'Fr',
        ),
      ]);
    } catch (e) {
      // Игнорируем ошибки при загрузке демо-данных
    }
  }

  Future<void> refreshData() async {
    // Обновляем новости из API
    await loadNews(
      country: _selectedCountry,
      category: _mapCategoryToApiCategory(_selectedCategory),
      sources: _selectedSources,
    );

    // Обновляем курсы валют (демо - случайное изменение)
    for (var i = 0; i < _currencyRates.length; i++) {
      final change = (Random().nextDouble() * 2 - 1) * 0.5;
      final currentRate = _currencyRates[i].rate;
      final newRate = currentRate + change;
      final changePercent = (change / currentRate) * 100;

      _currencyRates[i] = _currencyRates[i].copyWith(
        rate: double.parse(newRate.toStringAsFixed(4)),
        change: double.parse(change.toStringAsFixed(4)),
        changePercent: double.parse(changePercent.toStringAsFixed(2)),
      );
    }

    notifyListeners();
  }

  void setCategory(NewsCategory category) {
    _selectedCategory = category;
    // Автоматически загружаем новости при смене категории
    loadNews(category: _mapCategoryToApiCategory(category));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // Автоматически ищем новости при изменении запроса (с задержкой)
    if (query.isNotEmpty) {
      _debounceSearch();
    } else {
      // Если запрос пустой, загружаем обычные новости
      loadNews();
    }
  }

  void setCountry(String? country) {
    _selectedCountry = country;
    loadNews(country: country);
  }

  void setSources(List<String>? sources) {
    _selectedSources = sources;
    loadNews(sources: sources);
  }

  String? get selectedCountry => _selectedCountry;
  List<String>? get selectedSources => _selectedSources;

  // Debounce для поиска (чтобы не делать запрос при каждом символе)
  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery.isNotEmpty) {
        loadNews();
      }
    });
  }

  void toggleShowOnlyUnread() {
    _showOnlyUnread = !_showOnlyUnread;
    notifyListeners();
  }

  Future<void> markAsRead(String articleId) async {
    final index = _newsArticles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _newsArticles[index] = _newsArticles[index].copyWith(isRead: true);
      notifyListeners();
      
      // Сохраняем в локальное хранилище через UseCase
      try {
        await _markAsReadUseCase.call(articleId);
      } catch (e) {
        // Игнорируем ошибки при сохранении статуса прочтения
      }
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (var i = 0; i < _newsArticles.length; i++) {
      if (!_newsArticles[i].isRead) {
        _newsArticles[i] = _newsArticles[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Дополнительные методы

  NewsArticle? getArticleById(String id) {
    try {
      return _newsArticles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  List<NewsArticle> getArticlesBySource(String source) {
    return _newsArticles.where((article) => article.source == source).toList();
  }

  List<NewsArticle> getUnreadArticles() {
    return _newsArticles.where((article) => !article.isRead).toList();
  }

  int getUnreadCount() {
    return _newsArticles.where((article) => !article.isRead).length;
  }

  int getUnreadCountByCategory(NewsCategory category) {
    return _newsArticles
        .where((article) => article.category == category && !article.isRead)
        .length;
  }

  void addArticle(NewsArticle article) {
    _newsArticles.insert(0, article); // Добавляем в начало
    notifyListeners();
  }

  void removeArticle(String id) {
    _newsArticles.removeWhere((article) => article.id == id);
    notifyListeners();
  }

  void updateArticle(NewsArticle article) {
    final index = _newsArticles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _newsArticles[index] = article;
      notifyListeners();
    }
  }

  CurrencyRate? getCurrencyRate(String code) {
    try {
      return _currencyRates.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  void updateCurrencyRate(CurrencyRate currency) {
    final index = _currencyRates.indexWhere((c) => c.code == currency.code);
    if (index != -1) {
      _currencyRates[index] = currency;
      notifyListeners();
    }
  }

  void addCurrencyRate(CurrencyRate currency) {
    if (!_currencyRates.any((c) => c.code == currency.code)) {
      _currencyRates.add(currency);
      notifyListeners();
    }
  }

  void removeCurrencyRate(String code) {
    _currencyRates.removeWhere((currency) => currency.code == code);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = NewsCategory.finance;
    _searchQuery = '';
    _showOnlyUnread = false;
    notifyListeners();
  }

  // Статистика
  int get totalArticles => _newsArticles.length;

  int getArticlesCountByCategory(NewsCategory category) {
    return _newsArticles.where((article) => article.category == category).length;
  }

  List<NewsCategory> getCategoriesByArticleCount() {
    final counts = <NewsCategory, int>{};
    for (final category in NewsCategory.values) {
      counts[category] = getArticlesCountByCategory(category);
    }

    return counts.entries
        .toList()
        .sorted((a, b) => b.value.compareTo(a.value))
        .map((e) => e.key)
        .toList();
  }

  /// Преобразование NewsArticleEntity в NewsArticle модель
  NewsArticle _entityToModel(NewsArticleEntity entity) {
    return NewsArticle(
      id: entity.id,
      title: entity.title,
      summary: entity.summary,
      content: entity.content,
      imageUrl: entity.imageUrl,
      category: entity.category,
      source: entity.source,
      publishedAt: entity.publishedAt,
      url: entity.url,
      isRead: entity.isRead,
    );
  }

  /// Маппинг категории приложения в категорию NewsAPI
  String _mapCategoryToApiCategory(NewsCategory category) {
    switch (category) {
      case NewsCategory.finance:
      case NewsCategory.economy:
      case NewsCategory.personalFinance:
        return 'business';
      case NewsCategory.crypto:
      case NewsCategory.stocks:
        return 'business';
      default:
        return 'business';
    }
  }

  /// Извлечение сообщения об ошибке из исключения
  String _extractErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }

    if (error is NoInternetException) {
      return 'Нет подключения к интернету';
    }

    if (error is TimeoutException) {
      return 'Превышено время ожидания. Проверьте подключение к интернету';
    }

    if (error is RateLimitException) {
      return 'Превышен лимит запросов. Попробуйте позже';
    }

    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }

    return 'Произошла ошибка при загрузке новостей';
  }
}

extension ListSort<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}