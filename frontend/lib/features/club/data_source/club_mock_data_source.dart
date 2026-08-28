import 'club_data_source.dart';
import '../models/club_model.dart';

/// TODO(backend): 동아리 목록/즐겨찾기 API(GET /clubs/me, GET /clubs,
/// PATCH /clubs/{id}/favorite 등)가 아직 openapi.yaml에 없어서 임시로
/// 메모리에서만 동작하는 목데이터를 반환하는 구현체. 실제 API가 추가되면
/// 다른 features의 *ApiDataSourceImpl들처럼 ApiClient(Dio)를 쓰는
/// ClubApiDataSourceImpl로 교체하고, DI(di_providers.dart)의
/// clubDataSourceProvider가 그쪽을 가리키도록 한 줄만 바꾸면 된다 — 이 파일
/// 하나만 걷어내면 되도록 인터페이스를 분리해뒀다.
///
/// 검색 화면에서 "가입된 동아리 / 가입하지 않은 동아리"를 나눠 보여줄 수
/// 있도록, 실제로 가입한(isJoined: true) 동아리 5개 외에 아직 가입하지
/// 않은(isJoined: false) 동아리도 몇 개 목데이터에 섞어뒀다.
final class ClubMockDataSourceImpl implements ClubDataSource {
  final List<ClubModel> _clubs = [
    const ClubModel(
      id: 1,
      name: '알고리즘 스터디',
      leaderName: '박승찬',
      category: '학술',
      memberCount: 24,
      isJoined: true,
      isFavorite: true,
    ),
    const ClubModel(
      id: 2,
      name: '사진 동아리 셔터',
      leaderName: '박승찬',
      category: '취미',
      memberCount: 18,
      isJoined: true,
      isFavorite: true,
    ),
    const ClubModel(
      id: 3,
      name: '농구 동아리',
      leaderName: '박승찬',
      category: '체육',
      memberCount: 32,
      isJoined: true,
    ),
    const ClubModel(
      id: 4,
      name: '창업 연합회',
      leaderName: '박승찬',
      category: '학술',
      memberCount: 15,
      isJoined: true,
    ),
    const ClubModel(
      id: 5,
      name: '밴드 동아리 사운드',
      leaderName: '박승찬',
      category: '문화예술',
      memberCount: 21,
      isJoined: true,
    ),
    // 아직 가입하지 않은 동아리(검색 결과에서 "가입하지 않은 동아리" 섹션에
    // 노출하기 위한 목데이터).
    const ClubModel(
      id: 6,
      name: '등산 동아리',
      leaderName: '박승찬',
      category: '체육',
      memberCount: 12,
      isJoined: false,
    ),
    const ClubModel(
      id: 7,
      name: '요리 연구회',
      leaderName: '박승찬',
      category: '취미',
      memberCount: 19,
      isJoined: false,
    ),
    const ClubModel(
      id: 8,
      name: '영화 감상 동아리',
      leaderName: '박승찬',
      category: '문화예술',
      memberCount: 27,
      isJoined: false,
    ),
  ];

  @override
  Future<List<ClubModel>> getMyClubs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_clubs.where((club) => club.isJoined));
  }

  @override
  Future<List<ClubModel>> getAllClubs() async {
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
