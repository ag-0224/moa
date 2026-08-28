import '../models/club_detail_model.dart';
import '../repositories/club_repository.dart';

class ApplyToClubUseCase {
  const ApplyToClubUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubDetailModel> call(int clubId, String selfIntroduction) =>
      _clubRepository.applyToClub(clubId, selfIntroduction);
}
