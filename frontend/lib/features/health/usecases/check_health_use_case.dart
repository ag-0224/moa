import '../models/health_status.dart';
import '../repositories/health_repository.dart';

class CheckHealthUseCase {
  const CheckHealthUseCase(this._healthRepository);

  final HealthRepository _healthRepository;

  Future<HealthStatus> call() => _healthRepository.check();
}
