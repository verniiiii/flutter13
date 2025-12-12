import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/news/state/news_store.dart';
import 'package:prac13/core/models/news_model.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<NewsStore>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Новости и курсы'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: store.isLoading ? null : store.refreshData,
              tooltip: 'Обновить данные',
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white, // Цвет активной вкладки
            unselectedLabelColor: Colors.white70, // Цвет неактивной вкладки
            indicatorColor: Colors.white, // Цвет индикатора
            indicatorWeight: 3, // Толщина индикатора
            tabs: const [
              Tab(icon: Icon(Icons.currency_exchange), text: 'Курсы'),
              Tab(icon: Icon(Icons.article), text: 'Новости'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Вкладка с курсами валют
            _buildCurrencyRatesTab(store, context),

            // Вкладка с новостями
            _buildNewsTab(store, context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRatesTab(NewsStore store, BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.currencyRates.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основные валюты
              const Text(
                'Основные валюты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...store.majorCurrencies.map((currency) =>
                  _buildCurrencyCard(currency, context)),

              const SizedBox(height: 24),

              // Остальные валюты
              const Text(
                'Другие валюты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...store.otherCurrencies.map((currency) =>
                  _buildCurrencyCard(currency, context)),

              const SizedBox(height: 20),

              // Информация об обновлении
              _buildLastUpdateInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyCard(CurrencyRate currency, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: currency.isPositive ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: currency.isPositive ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              currency.symbol,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: currency.isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        title: Text(
          '${currency.code} / RUB',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(currency.name),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${currency.rate.toStringAsFixed(2)} ₽',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currency.change >= 0 ? '+' : ''}${currency.change.toStringAsFixed(2)} '
                  '(${currency.changePercent >= 0 ? '+' : ''}${currency.changePercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                fontSize: 12,
                color: currency.isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsTab(NewsStore store, BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Column(
          children: [
            // Фильтры и поиск
            _buildNewsFilters(store, context),

            // Список новостей
            Expanded(
              child: _buildNewsList(store, context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewsFilters(NewsStore store, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: const InputDecoration(
              labelText: 'Поиск новостей',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: store.setSearchQuery,
          ),

          const SizedBox(height: 12),

          // Категории
          ListenableBuilder(
            listenable: store,
            builder: (context, _) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: NewsCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: store.selectedCategory == category,
                      onSelected: (_) => store.setCategory(category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Фильтр по стране
          Row(
            children: [
              const Text('Страна:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: store.selectedCountry ?? 'us',
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'us', child: Text('США')),
                    DropdownMenuItem(value: 'ru', child: Text('Россия')),
                    DropdownMenuItem(value: 'gb', child: Text('Великобритания')),
                    DropdownMenuItem(value: 'de', child: Text('Германия')),
                    DropdownMenuItem(value: 'fr', child: Text('Франция')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      store.setCountry(value);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Дополнительные фильтры
          ListenableBuilder(
            listenable: store,
            builder: (context, _) => Row(
              children: [
                const Text('Только непрочитанные'),
                const Spacer(),
                Switch(
                  value: store.showOnlyUnread,
                  onChanged: (_) => store.toggleShowOnlyUnread(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(NewsStore store, BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.newsArticles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final articles = store.filteredNews;

        if (store.hasError && articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    store.errorMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: store.refreshData,
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          );
        }

        if (articles.isEmpty && !store.isLoading) {
          return _buildEmptyNewsState(store, context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return _buildNewsArticle(article, store, context);
          },
        );
      },
    );
  }

  Widget _buildEmptyNewsState(NewsStore store, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: store,
            builder: (context, _) => Text(
              store.searchQuery.isNotEmpty
                  ? 'Новости не найдены'
                  : 'Нет новостей в выбранной категории',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Попробуйте изменить фильтры или обновить данные',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: store.refreshData,
            child: const Text('Обновить данные'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsArticle(NewsArticle article, NewsStore store, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          store.markAsRead(article.id);
          _showArticleDetails(context, article, store);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение
              if (article.imageUrl != null)
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и статус прочтения
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: article.isRead ? Colors.grey : Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!article.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Краткое описание
                    Text(
                      article.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Мета-информация
                    Row(
                      children: [
                        // Категория
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(article.category),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.category.displayName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Источник и время
                        Text(
                          '${article.source} • ${article.timeAgo}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdateInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Курсы обновляются автоматически каждые 5 минут',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            'Обновлено: ${_formatTime(DateTime.now())}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showArticleDetails(BuildContext context, NewsArticle article, NewsStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.7,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Мета-информация
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(article.category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.source,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Изображение
                if (article.imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(article.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Контент
                Text(
                  article.content ?? article.summary,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Кнопки действий
                if (article.url != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // В реальном приложении здесь будет открытие ссылки
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Переход к полной версии статьи'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Читать полностью'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(NewsCategory category) {
    switch (category) {
      case NewsCategory.finance:
        return Colors.blue;
      case NewsCategory.economy:
        return Colors.green;
      case NewsCategory.crypto:
        return Colors.orange;
      case NewsCategory.stocks:
        return Colors.purple;
      case NewsCategory.personalFinance:
        return Colors.teal;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}