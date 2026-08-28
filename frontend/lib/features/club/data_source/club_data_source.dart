import '../models/club_model.dart';

abstract interface class ClubDataSource {
  /// 로그인한 사용자가 소속된 동아리 목록.
  Future<List<ClubModel>> getMyClubs();

  /// 동아리 하나의 즐겨찾기 여부를 바꾼다.
  Future<void> setFavorite(int clubId, bool isFavorite);
}
