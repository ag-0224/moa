import '../models/club_member_model.dart';
import '../repositories/club_repository.dart';

class GetClubMembersUseCase {
  const GetClubMembersUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<List<ClubMemberModel>> call(int clubId) => _clubRepository.getClubMembers(clubId);
}
