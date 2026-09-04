import '../models/club_application_model.dart';
import '../repositories/club_repository.dart';

class RejectClubApplicationUseCase {
  const RejectClubApplicationUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubApplicationModel> call(int clubId, int applicationId) =>
      _clubRepository.rejectApplication(clubId, applicationId);
}
