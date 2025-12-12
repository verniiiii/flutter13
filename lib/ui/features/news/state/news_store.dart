import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/news_model.dart';

class NewsStore with ChangeNotifier {
  List<NewsArticle> _newsArticles = [];
  List<CurrencyRate> _currencyRates = [];
  bool _isLoading = false;
  String _errorMessage = '';
  NewsCategory _selectedCategory = NewsCategory.finance;
  String _searchQuery = '';
  bool _showOnlyUnread = false;

  List<NewsArticle> get newsArticles => List.unmodifiable(_newsArticles);
  List<CurrencyRate> get currencyRates => List.unmodifiable(_currencyRates);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  NewsCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get showOnlyUnread => _showOnlyUnread;
  bool get hasError => _errorMessage.isNotEmpty;

  List<NewsArticle> get filteredNews {
    var articles = _newsArticles.where((article) =>
    article.category == _selectedCategory).toList();

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

  NewsStore() {
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

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

      // Демо данные - новости
      _newsArticles.addAll([
        NewsArticle(
          id: '1',
          title: 'ЦБ РФ сохранил ключевую ставку на уровне 16%',
          summary: 'Банк России принял решение сохранить ключевую ставку на уровне 16% годовых.',
          content: 'Центральный банк Российской Федерации на заседании совета директоров принял решение сохранить ключевую ставку на уровне 16% годовых. Такое решение было ожидаемо большинством аналитиков.',
          imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=250&fit=crop',
          category: NewsCategory.finance,
          source: 'РБК',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          url: 'https://example.com/news/1',
        ),
        NewsArticle(
          id: '2',
          title: 'Курс доллара обновил максимум с начала года',
          summary: 'Доллар США на Московской бирже подорожал до 93 рублей.',
          content: 'Курс доллара США к рублю на Московской бирже в ходе торгов поднялся до 93 рублей, что стало максимальным значением с начала текущего года.',
          imageUrl: 'https://images.unsplash.com/photo-1604594849809-dfedbc827105?w=400&h=250&fit=crop',
          category: NewsCategory.finance,
          source: 'Коммерсантъ',
          publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
          url: 'https://example.com/news/2',
        ),
        NewsArticle(
          id: '3',
          title: 'Биткоин превысил \$50,000',
          summary: 'Крупнейшая криптовалюта впервые с 2021 года преодолела отметку в \$50,000.',
          content: 'Капитализация биткоина превысила \$1 триллион после роста цены выше \$50,000. Аналитики связывают рост с одобрением биткоин-ETF в США.',
          imageUrl: 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=400&h=250&fit=crop',
          category: NewsCategory.crypto,
          source: 'CoinDesk',
          publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
          url: 'https://example.com/news/3',
        ),
        NewsArticle(
          id: '4',
          title: 'Инфляция в РФ замедлилась до 7,2%',
          summary: 'Годовая инфляция в России в январе замедлилась до 7,2%.',
          content: 'По данным Росстата, годовая инфляция в России в январе замедлилась до 7,2% после 7,4% в декабре. Базовая инфляция составила 6,8%.',
          imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=250&fit=crop',
          category: NewsCategory.economy,
          source: 'Интерфакс',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          url: 'https://example.com/news/4',
        ),
        NewsArticle(
          id: '5',
          title: 'Советы по накоплению на первоначальный взгляд',
          summary: 'Эксперты рассказали, как эффективно копить на жилье в текущих условиях.',
          content: 'Финансовые консультанты рекомендуют откладывать не менее 20% дохода, использовать программы льготной ипотеки и рассматривать альтернативные варианты инвестиций.',
          imageUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=250&fit=crop',
          category: NewsCategory.personalFinance,
          source: 'Финансы.ru',
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
          url: 'https://example.com/news/5',
        ),
        NewsArticle(
          id: '6',
          title: 'Акции Сбербанка выросли на 3%',
          summary: 'Ценные бумаги Сбербанка показали лучшую динамику среди голубых фишек.',
          content: 'Акции ПАО Сбербанк на Московской бирже подорожали на 3% после публикации сильных отчетных результатов за четвертый квартал.',
          imageUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=400&h=250&fit=crop',
          category: NewsCategory.stocks,
          source: 'Ведомости',
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
          url: 'https://example.com/news/6',
        ),
      ]);

    } catch (e) {
      _errorMessage = 'Ошибка загрузки данных';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3));
      // В реальном приложении здесь будет обновление данных с API

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
    } catch (e) {
      _errorMessage = 'Ошибка обновления данных';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(NewsCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowOnlyUnread() {
    _showOnlyUnread = !_showOnlyUnread;
    notifyListeners();
  }

  void markAsRead(String articleId) {
    final index = _newsArticles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _newsArticles[index] = _newsArticles[index].copyWith(isRead: true);
      notifyListeners();
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
}

extension ListSort<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}