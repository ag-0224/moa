import '../models/club_model.dart';

abstract interface class ClubRepository {
  Future<List<ClubModel>> getMyClubs();

  Future<List<ClubModel>> getAllClubs();

  Future<void> setFavorite(int clubId, bool isFavorite);
}
