import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/motivation/state/motivation_store.dart';
import 'package:prac13/core/models/motivation_model.dart';

class MotivationScreen extends StatelessWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<MotivationStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мотивация'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => _showFavoritesDialog(context, store),
            tooltip: 'Избранное',
          ),
        ],
      ),
      body: Column(
        children: [
          // Сегментированные кнопки для выбора типа контента
          _buildContentTypeSelector(store),

          // Основной контент
          Expanded(
            child: _buildContentArea(context, store),
          ),

          // Кнопки действий
          _buildActionButtons(store),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector(MotivationStore store) {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SegmentedButton<ContentType>(
          segments: const [
            ButtonSegment<ContentType>(
              value: ContentType.quote,
              label: Text('Цитаты'),
              icon: Icon(Icons.format_quote),
            ),
            ButtonSegment<ContentType>(
              value: ContentType.affirmation,
              label: Text('Аффирмации'),
              icon: Icon(Icons.self_improvement),
            ),
            ButtonSegment<ContentType>(
              value: ContentType.tip,
              label: Text('Советы'),
              icon: Icon(Icons.lightbulb),
            ),
          ],
          selected: {store.selectedType},
          onSelectionChanged: (Set<ContentType> newSelection) {
            store.setContentType(newSelection.first);
          },
        ),
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, MotivationStore store) {
    return Observer(
      builder: (_) {
        if (store.currentContent == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final content = store.currentContent!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Декоративный элемент
              _buildDecorativeElement(content.type),

              const SizedBox(height: 32),

              // Текст контента
              _buildContentText(context, content),

              const SizedBox(height: 16),

              // Автор (если есть)
              if (content.author != null)
                _buildAuthorText(context, content.author!),

              const SizedBox(height: 8),

              // Категория
              _buildCategoryChip(content.category),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorativeElement(ContentType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ContentType.quote:
        icon = Icons.format_quote;
        color = Colors.blue;
        break;
      case ContentType.affirmation:
        icon = Icons.self_improvement;
        color = Colors.green;
        break;
      case ContentType.tip:
        icon = Icons.lightbulb;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Widget _buildContentText(BuildContext context, MotivationContent content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        content.text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAuthorText(BuildContext context, String author) {
    return Text(
      '— $author',
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCategoryChip(String category) {
    return Chip(
      label: Text(
        category,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[100],
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButtons(MotivationStore store) {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Кнопка избранного
            Expanded(
              child: IconButton(
                onPressed: store.toggleFavorite,
                icon: Icon(
                  store.currentContent?.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: store.currentContent?.isFavorite == true
                      ? Colors.red
                      : Colors.grey,
                ),
                tooltip: 'Добавить в избранное',
              ),
            ),

            // Кнопка новой цитаты
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: store.getNewContent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.autorenew),
                label: const Text('Новая цитата'),
              ),
            ),

            // Кнопка поделиться
            Expanded(
              child: IconButton(
                onPressed: () => _shareContent(store),
                icon: const Icon(Icons.share),
                tooltip: 'Поделиться',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoritesDialog(BuildContext context, MotivationStore store) {
    showDialog(
      context: context,
      builder: (context) => Observer(
        builder: (_) => AlertDialog(
          title: const Text('Избранное'),
          content: store.favorites.isEmpty
              ? const Text('У вас пока нет избранных цитат')
              : SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: store.favorites.length,
              itemBuilder: (context, index) {
                final favorite = store.favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getTypeIcon(favorite.type),
                      color: _getTypeColor(favorite.type),
                    ),
                    title: Text(
                      favorite.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: favorite.author != null
                        ? Text('— ${favorite.author}')
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        store.toggleFavorite();
                        // После удаления из избранного нужно обновить диалог
                        Navigator.pop(context);
                        _showFavoritesDialog(context, store);
                      },
                    ),
                    onTap: () {
                      store.currentContent = favorite;
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.quote:
        return Icons.format_quote;
      case ContentType.affirmation:
        return Icons.self_improvement;
      case ContentType.tip:
        return Icons.lightbulb;
    }
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.quote:
        return Colors.blue;
      case ContentType.affirmation:
        return Colors.green;
      case ContentType.tip:
        return Colors.orange;
    }
  }

  void _shareContent(MotivationStore store) {
    if (store.currentContent != null) {
      final content = store.currentContent!;
      final shareText = content.author != null
          ? '${content.text}\n— ${content.author}'
          : content.text;

      // В реальном приложении здесь будет вызов нативного шеринга
      ScaffoldMessenger.of(store as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Цитата скопирована: "$shareText"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}