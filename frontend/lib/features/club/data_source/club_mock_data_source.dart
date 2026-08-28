import 'club_data_source.dart';
import '../models/club_model.dart';

/// TODO(backend): 동아리 목록 API(GET /clubs/me 등)가 아직 openapi.yaml에 없어서
/// 임시로 목데이터를 반환하는 구현체. 실제 API가 추가되면 다른 features의
/// *ApiDataSourceImpl들처럼 ApiClient(Dio)를 쓰는 ClubApiDataSourceImpl로
/// 교체하고, DI(di_providers.dart)의 clubDataSourceProvider가 그쪽을 가리키도록
/// 한 줄만 바꾸면 된다 — 이 파일 하나만 걷어내면 되도록 인터페이스를 분리해뒀다.
final class ClubMockDataSourceImpl implements ClubDataSource {
  @override
  Future<List<ClubModel>> getMyClubs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ClubModel(id: 1, name: '알고리즘 스터디', category: '학술', memberCount: 24, isFavorite: true),
      ClubModel(id: 2, name: '사진 동아리 셔터', category: '취미', memberCount: 18, isFavorite: true),
      ClubModel(id: 3, name: '농구 동아리', category: '체육', memberCount: 32),
      ClubModel(id: 4, name: '창업 연합회', category: '학술', memberCount: 15),
      ClubModel(id: 5, name: '밴드 동아리 사운드', category: '문화예술', memberCount: 21),
    ];
  }
}
