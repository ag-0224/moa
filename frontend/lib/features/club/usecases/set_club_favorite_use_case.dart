import '../repositories/club_repository.dart';

class SetClubFavoriteUseCase {
  const SetClubFavoriteUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<void> call(int clubId, bool isFavorite) => _clubRepository.setFavorite(clubId, isFavorite);
}
