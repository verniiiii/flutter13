import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/onboarding/state/onboarding_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingStore store = GetIt.I<OnboardingStore>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final currentPage = store.pages[store.currentPageIndex];
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: currentPage.gradientColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Хедер с пропуском
                  _buildHeader(context),

                  // Индикаторы прогресса
                  _buildProgressIndicator(),

                  // Основной контент с PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: store.pages.length,
                      onPageChanged: (index) {
                        store.goToPage(index);
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingPageContent(
                          page: store.pages[index],
                          pageIndex: index,
                        );
                      },
                    ),
                  ),

                  // Навигация
                  _buildBottomNavigation(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Логотип
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
            ),

            // Кнопка пропуска (скрывается на последней странице)
            if (!store.isLastPage)
              TextButton(
                onPressed: () {
                  store.completeOnboarding();
                  context.go('/');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            store.pages.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index == store.currentPageIndex ? 32 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index == store.currentPageIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Кнопка "Назад"
            if (!store.isFirstPage)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    store.previousPage();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 16),
                      SizedBox(width: 4),
                      Text('Назад'),
                    ],
                  ),
                ),
              ),

            if (!store.isFirstPage) const SizedBox(width: 12),

            // Кнопка "Далее" или "Начать"
            Expanded(
              flex: store.isFirstPage ? 1 : 2,
              child: ElevatedButton(
                onPressed: () {
                  if (store.isLastPage) {
                    store.completeOnboarding();
                    context.go('/login');
                  } else {
                    store.nextPage();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: store.pages[store.currentPageIndex].gradientColors.first,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      store.isLastPage ? 'Начать путешествие' : 'Продолжить',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!store.isLastPage) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;
  final int pageIndex;

  const _OnboardingPageContent({
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Анимированная иконка
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.icon,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Заголовок с анимацией
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: 1,
            child: Text(
              page.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Подзаголовок
          AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity: 1,
            child: Text(
              page.subtitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Описание
          AnimatedOpacity(
            duration: const Duration(milliseconds: 900),
            opacity: 1,
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Декоративные элементы
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorCircle(0.3, 20),
              const SizedBox(width: 8),
              _buildDecorCircle(0.5, 30),
              const SizedBox(width: 8),
              _buildDecorCircle(0.7, 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorCircle(double opacity, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}