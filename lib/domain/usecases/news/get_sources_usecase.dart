import '../../repositories/news_repository.dart';
import '../../../data/datasources/remote/dto/news_api_dto.dart';

class GetSourcesUseCase {
  final NewsRepository repository;

  GetSourcesUseCase(this.repository);

  Future<List<NewsSourceDto>> call({
    String? category,
    String? language,
    String? country,
  }) {
    return repository.getSources(
      category: category,
      language: language,
      country: country,
    );
  }
}

