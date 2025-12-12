import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/motivation_model.dart';

class MotivationStore with ChangeNotifier {
  List<MotivationContent> _allContent = [];
  MotivationContent? _currentContent;
  ContentType _selectedType = ContentType.quote;
  bool _isLoading = false;
  String _errorMessage = '';
  List<MotivationContent> _favorites = [];

  List<MotivationContent> get allContent => List.unmodifiable(_allContent);
  MotivationContent? get currentContent => _currentContent;
  ContentType get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<MotivationContent> get favorites => List.unmodifiable(_favorites);
  bool get hasError => _errorMessage.isNotEmpty;

  List<MotivationContent> get filteredContent => _allContent
      .where((content) => content.type == _selectedType)
      .toList();

  MotivationStore() {
    _initializeContent();
  }

  set currentContent(MotivationContent? value) {
    _currentContent = value;
    notifyListeners();
  }

  void _initializeContent() {
    // Цитаты
    _allContent.addAll([
      MotivationContent(
        id: '1',
        text: 'Единственный способ сделать что-то очень хорошо — любить то, что ты делаешь.',
        author: 'Стив Джобс',
        type: ContentType.quote,
        category: 'Успех',
      ),
      MotivationContent(
        id: '2',
        text: 'Не откладывай на завтра то, что можешь сделать сегодня.',
        author: 'Бенджамин Франклин',
        type: ContentType.quote,
        category: 'Продуктивность',
      ),
      MotivationContent(
        id: '3',
        text: 'Успех — это способность идти от failure к failure без потери энтузиазма.',
        author: 'Уинстон Черчилль',
        type: ContentType.quote,
        category: 'Настойчивость',
      ),
      MotivationContent(
        id: '4',
        text: 'Лучший способ предсказать будущее — создать его.',
        author: 'Питер Друкер',
        type: ContentType.quote,
        category: 'Действие',
      ),
      MotivationContent(
        id: '5',
        text: 'Ваше время ограничено, не тратьте его, живя чужой жизнью.',
        author: 'Стив Джобс',
        type: ContentType.quote,
        category: 'Саморазвитие',
      ),
    ]);

    // Аффирмации
    _allContent.addAll([
      MotivationContent(
        id: '6',
        text: 'Я достоин успеха и процветания',
        type: ContentType.affirmation,
        category: 'Уверенность',
      ),
      MotivationContent(
        id: '7',
        text: 'Каждый день я становлюсь лучше',
        type: ContentType.affirmation,
        category: 'Рост',
      ),
      MotivationContent(
        id: '8',
        text: 'Я привлекаю изобилие в свою жизнь',
        type: ContentType.affirmation,
        category: 'Изобилие',
      ),
      MotivationContent(
        id: '9',
        text: 'Мои мысли создают мою реальность',
        type: ContentType.affirmation,
        category: 'Сознание',
      ),
      MotivationContent(
        id: '10',
        text: 'Я благодарен за все, что имею',
        type: ContentType.affirmation,
        category: 'Благодарность',
      ),
    ]);

    // Советы
    _allContent.addAll([
      MotivationContent(
        id: '11',
        text: 'Начните свой день с 15 минут медитации',
        type: ContentType.tip,
        category: 'Утро',
      ),
      MotivationContent(
        id: '12',
        text: 'Записывайте 3 вещи, за которые вы благодарны каждый день',
        type: ContentType.tip,
        category: 'Привычки',
      ),
      MotivationContent(
        id: '13',
        text: 'Разбейте большие цели на маленькие шаги',
        type: ContentType.tip,
        category: 'Планирование',
      ),
      MotivationContent(
        id: '14',
        text: 'Проводите время на природе хотя бы 20 минут в день',
        type: ContentType.tip,
        category: 'Здоровье',
      ),
      MotivationContent(
        id: '15',
        text: 'Читайте 15 минут перед сном вместо телефона',
        type: ContentType.tip,
        category: 'Отдых',
      ),
    ]);

    // Устанавливаем случайный контент при инициализации
    _getRandomContent();
  }

  void _getRandomContent() {
    final availableContent = filteredContent;
    if (availableContent.isNotEmpty) {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % availableContent.length;
      _currentContent = availableContent[randomIndex];
      notifyListeners();
    }
  }

  void getNewContent() {
    _getRandomContent();
  }

  void setContentType(ContentType type) {
    _selectedType = type;
    _getRandomContent();
    notifyListeners();
  }

  void toggleFavorite() {
    if (_currentContent != null) {
      final index = _allContent.indexWhere((content) => content.id == _currentContent!.id);
      if (index != -1) {
        final updatedContent = _currentContent!.copyWith(isFavorite: !_currentContent!.isFavorite);
        _allContent[index] = updatedContent;
        _currentContent = updatedContent;

        // Обновляем список избранного
        if (updatedContent.isFavorite) {
          if (!_favorites.any((fav) => fav.id == updatedContent.id)) {
            _favorites.add(updatedContent);
          }
        } else {
          _favorites.removeWhere((fav) => fav.id == updatedContent.id);
        }

        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Дополнительные методы для управления контентом
  void addContent(MotivationContent content) {
    _allContent.add(content);
    notifyListeners();
  }

  void removeContent(String id) {
    _allContent.removeWhere((content) => content.id == id);
    _favorites.removeWhere((fav) => fav.id == id);
    if (_currentContent?.id == id) {
      _getRandomContent();
    }
    notifyListeners();
  }

  void updateContent(MotivationContent content) {
    final index = _allContent.indexWhere((c) => c.id == content.id);
    if (index != -1) {
      _allContent[index] = content;

      // Обновляем в избранном если там есть
      final favIndex = _favorites.indexWhere((fav) => fav.id == content.id);
      if (favIndex != -1) {
        _favorites[favIndex] = content;
      }

      // Обновляем текущий если это он
      if (_currentContent?.id == content.id) {
        _currentContent = content;
      }

      notifyListeners();
    }
  }

  List<MotivationContent> getContentByCategory(String category) {
    return _allContent.where((content) => content.category == category).toList();
  }

  // Получить случайную мотивацию по категории
  MotivationContent? getRandomContentByCategory(String category) {
    final categoryContent = _allContent.where((c) => c.category == category).toList();
    if (categoryContent.isEmpty) return null;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % categoryContent.length;
    return categoryContent[randomIndex];
  }

  // Получить статистику
  int getContentCountByType(ContentType type) {
    return _allContent.where((c) => c.type == type).length;
  }

  int getFavoriteCountByType(ContentType type) {
    return _favorites.where((fav) => fav.type == type).length;
  }
}