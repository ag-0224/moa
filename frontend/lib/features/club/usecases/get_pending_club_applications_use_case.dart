import '../models/club_application_model.dart';
import '../repositories/club_repository.dart';

class GetPendingClubApplicationsUseCase {
  const GetPendingClubApplicationsUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<List<ClubApplicationModel>> call(int clubId) => _clubRepository.getPendingApplications(clubId);
}
