import '../../repositories/news_repository.dart';
import '../../entities/news_entity.dart';

class GetCurrencyRatesUseCase {
  final NewsRepository repository;

  GetCurrencyRatesUseCase(this.repository);

  Future<List<CurrencyRateEntity>> call() {
    return repository.getCurrencyRates();
  }
}

