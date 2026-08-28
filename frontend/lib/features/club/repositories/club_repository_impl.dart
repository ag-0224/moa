import '../data_source/club_data_source.dart';
import '../models/club_model.dart';
import 'club_repository.dart';

final class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._clubDataSource);

  final ClubDataSource _clubDataSource;

  @override
  Future<List<ClubModel>> getMyClubs() => _clubDataSource.getMyClubs();

  @override
  Future<void> setFavorite(int clubId, bool isFavorite) => _clubDataSource.setFavorite(clubId, isFavorite);
}
