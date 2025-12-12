import 'dart:ui';

import 'package:flutter/foundation.dart';

class OnboardingStore with ChangeNotifier {
  int _currentPageIndex = 0;
  bool _isCompleted = false;

  int get currentPageIndex => _currentPageIndex;
  bool get isCompleted => _isCompleted;
  bool get isLastPage => _currentPageIndex == pages.length - 1;
  bool get isFirstPage => _currentPageIndex == 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Взгляните на свои финансы по-новому',
      subtitle: 'Простое управление бюджетом',
      description: 'Отслеживайте все доходы и расходы в одном месте. Полный контроль над вашими деньгами.',
      icon: '💰',
      gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    OnboardingPage(
      title: 'Умная аналитика',
      subtitle: 'Понимайте свои привычки',
      description: 'Наглядные графики и отчёты покажут, куда уходят деньги и как оптимизировать расходы.',
      icon: '📊',
      gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    OnboardingPage(
      title: 'Достигайте целей',
      subtitle: 'Мечты становятся реальностью',
      description: 'Ставьте финансовые цели и отслеживайте прогресс. Мы поможем вам накопить на важное.',
      icon: '🎯',
      gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
    OnboardingPage(
      title: 'Все карты под контролем',
      subtitle: 'Удобное управление',
      description: 'Добавляйте все ваши карты, отслеживайте балансы и получайте умные уведомления.',
      icon: '💳',
      gradientColors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
    ),
  ];

  void nextPage() {
    if (_currentPageIndex < pages.length - 1) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  void completeOnboarding() {
    _isCompleted = true;
    notifyListeners();
  }

  void goToPage(int index) {
    if (index >= 0 && index < pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  void resetOnboarding() {
    _currentPageIndex = 0;
    _isCompleted = false;
    notifyListeners();
  }

  // Дополнительные методы для удобства
  OnboardingPage get currentPage => pages[_currentPageIndex];

  double get progress => (_currentPageIndex + 1) / pages.length;

  void skipToLast() {
    _currentPageIndex = pages.length - 1;
    notifyListeners();
  }

  bool hasSeenAllPages() {
    return _currentPageIndex >= pages.length - 1;
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}