import '../models/club_detail_model.dart';
import '../repositories/club_repository.dart';

class GetClubDetailUseCase {
  const GetClubDetailUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubDetailModel> call(int clubId) => _clubRepository.getClubDetail(clubId);
}
