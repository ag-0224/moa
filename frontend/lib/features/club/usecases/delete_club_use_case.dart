import '../repositories/club_repository.dart';

/// 스터디 관리 페이지 "스터디 삭제" 확인 다이얼로그가 쓰는 유스케이스.
class DeleteClubUseCase {
  const DeleteClubUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<void> call(int clubId) => _clubRepository.deleteClub(clubId);
}
