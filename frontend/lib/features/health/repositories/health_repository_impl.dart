import '../data_source/health_api_data_source.dart';
import '../models/health_status.dart';
import 'health_repository.dart';

final class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(this._healthApiDataSource);

  final HealthApiDataSource _healthApiDataSource;

  @override
  Future<HealthStatus> check() => _healthApiDataSource.check();
}
