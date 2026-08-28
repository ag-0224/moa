import '../models/club_model.dart';
import '../repositories/club_repository.dart';

class GetAllClubsUseCase {
  const GetAllClubsUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<List<ClubModel>> call() => _clubRepository.getAllClubs();
}
