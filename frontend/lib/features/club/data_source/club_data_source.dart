import '../models/club_model.dart';

abstract interface class ClubDataSource {
  /// 로그인한 사용자가 소속된(가입된) 동아리 목록.
  Future<List<ClubModel>> getMyClubs();

  /// 가입 여부와 상관없이 전체 동아리 목록. 검색에서 가입/미가입을 나눠
  /// 보여주기 위해 쓴다.
  Future<List<ClubModel>> getAllClubs();

  /// 동아리 하나의 즐겨찾기 여부를 바꾼다.
  Future<void> setFavorite(int clubId, bool isFavorite);
}
