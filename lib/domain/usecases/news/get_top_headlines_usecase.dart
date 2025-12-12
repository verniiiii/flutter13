import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class GetTopHeadlinesUseCase {
  final NewsRepository repository;

  GetTopHeadlinesUseCase(this.repository);

  Future<List<NewsArticleEntity>> call({
    String? country,
    String? category,
    List<String>? sources,
    int pageSize = 20,
    int page = 1,
  }) {
    return repository.getTopHeadlines(
      country: country,
      category: category,
      sources: sources,
      pageSize: pageSize,
      page: page,
    );
  }
}

