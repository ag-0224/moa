import '../models/club_detail_model.dart';
import '../repositories/club_repository.dart';

class TransferClubLeadershipUseCase {
  const TransferClubLeadershipUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubDetailModel> call(int clubId, int newLeaderId) =>
      _clubRepository.transferLeadership(clubId, newLeaderId);
}
