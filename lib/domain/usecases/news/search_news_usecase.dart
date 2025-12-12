import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class SearchNewsUseCase {
  final NewsRepository repository;

  SearchNewsUseCase(this.repository);

  Future<List<NewsArticleEntity>> call({
    String? query,
    List<String>? sources,
    List<String>? domains,
    DateTime? from,
    DateTime? to,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  }) {
    return repository.searchNews(
      query: query,
      sources: sources,
      domains: domains,
      from: from,
      to: to,
      language: language,
      sortBy: sortBy,
      pageSize: pageSize,
      page: page,
    );
  }
}

