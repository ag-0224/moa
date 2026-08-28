import 'club_data_source.dart';
import '../models/club_model.dart';

/// TODO(backend): 동아리 목록/즐겨찾기 API(GET /clubs/me, PATCH /clubs/{id}/favorite
/// 등)가 아직 openapi.yaml에 없어서 임시로 메모리에서만 동작하는 목데이터를
/// 반환하는 구현체. 실제 API가 추가되면 다른 features의 *ApiDataSourceImpl들처럼
/// ApiClient(Dio)를 쓰는 ClubApiDataSourceImpl로 교체하고, DI(di_providers.dart)의
/// clubDataSourceProvider가 그쪽을 가리키도록 한 줄만 바꾸면 된다 — 이 파일
/// 하나만 걷어내면 되도록 인터페이스를 분리해뒀다.
final class ClubMockDataSourceImpl implements ClubDataSource {
  final List<ClubModel> _clubs = [
    const ClubModel(
      id: 1,
      name: '알고리즘 스터디',
      leaderName: '박승찬',
      category: '학술',
      memberCount: 24,
      isFavorite: true,
    ),
    const ClubModel(
      id: 2,
      name: '사진 동아리 셔터',
      leaderName: '박승찬',
      category: '취미',
      memberCount: 18,
      isFavorite: true,
    ),
    const ClubModel(id: 3, name: '농구 동아리', leaderName: '박승찬', category: '체육', memberCount: 32),
    const ClubModel(id: 4, name: '창업 연합회', leaderName: '박승찬', category: '학술', memberCount: 15),
    const ClubModel(
      id: 5,
      name: '밴드 동아리 사운드',
      leaderName: '박승찬',
      category: '문화예술',
      memberCount: 21,
    ),
  ];

  @override
  Future<List<ClubModel>> getMyClubs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_clubs);
  }

  @override
  Future<void> setFavorite(int clubId, bool isFavorite) async {
    final index = _clubs.indexWhere((club) => club.id == clubId);
    if (index == -1) return;
    _clubs[index] = _clubs[index].copyWith(isFavorite: isFavorite);
  }
}
