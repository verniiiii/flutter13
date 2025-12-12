import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class GetNewsUseCase {
  final NewsRepository repository;

  GetNewsUseCase(this.repository);

  Future<List<NewsArticleEntity>> call() {
    return repository.getNews();
  }
}

