import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class GetNewsByCategoryUseCase {
  final NewsRepository repository;

  GetNewsByCategoryUseCase(this.repository);

  Future<List<NewsArticleEntity>> call({
    required String category,
    String? country,
    int pageSize = 20,
    int page = 1,
  }) {
    return repository.getNewsByCategory(
      category: category,
      country: country,
      pageSize: pageSize,
      page: page,
    );
  }
}

