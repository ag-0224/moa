import '../models/club_model.dart';

abstract interface class ClubRepository {
  Future<List<ClubModel>> getMyClubs();
}
