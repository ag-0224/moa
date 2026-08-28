import '../data_source/club_data_source.dart';
import '../models/club_detail_model.dart';
import '../models/club_model.dart';
import 'club_repository.dart';

final class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._clubDataSource);

  final ClubDataSource _clubDataSource;

  @override
  Future<List<ClubModel>> getMyClubs() => _clubDataSource.getMyClubs();

  @override
  Future<List<ClubModel>> getAllClubs() => _clubDataSource.getAllClubs();

  @override
  Future<void> setFavorite(int clubId, bool isFavorite) => _clubDataSource.setFavorite(clubId, isFavorite);

  @override
  Future<ClubDetailModel> getClubDetail(int clubId) => _clubDataSource.getClubDetail(clubId);

  @override
  Future<ClubDetailModel> applyToClub(int clubId, String selfIntroduction) =>
      _clubDataSource.applyToClub(clubId, selfIntroduction);
}
