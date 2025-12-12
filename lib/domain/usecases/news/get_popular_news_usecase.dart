import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class GetPopularNewsUseCase {
  final NewsRepository repository;

  GetPopularNewsUseCase(this.repository);

  Future<List<NewsArticleEntity>> call({
    String? language,
    int pageSize = 20,
    int page = 1,
  }) {
    return repository.getPopularNews(
      language: language,
      pageSize: pageSize,
      page: page,
    );
  }
}

