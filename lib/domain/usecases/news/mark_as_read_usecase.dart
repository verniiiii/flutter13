import '../../repositories/news_repository.dart';

class MarkAsReadUseCase {
  final NewsRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<void> call(String newsId) {
    return repository.markAsRead(newsId);
  }
}

