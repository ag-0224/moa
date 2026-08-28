/// 동아리 하나를 나타내는 모델. 메인 페이지(홈 피드)의 "내가 속한 동아리
/// 목록"과 검색 결과(가입/미가입 동아리 전체)에서 공통으로 쓴다.
///
/// fromJson은 openapi.yaml의 Club 스키마(GET /clubs, GET /clubs/me, PATCH
/// /clubs/{clubId}/favorite 응답)를 그대로 매핑한다. 서버 DTO(ClubResponse)가
/// joined/favorite로 내려주므로(isJoined/isFavorite가 아님 — Jackson이 record의
/// is-prefixed boolean 컴포넌트를 bean 프로퍼티로 오인해 벗겨내는 걸 피하려고
/// 백엔드에서 일부러 그렇게 정했다), 이 모델의 필드명(isJoined/isFavorite)과는
/// 다르다는 점에 유의한다.
class ClubModel {
  const ClubModel({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.category,
    required this.memberCount,
    required this.isJoined,
    this.thumbnailUrl,
    this.isFavorite = false,
  });

  final int id;
  final String name;

  /// 동아리 대표(회장) 이름. 목록 설명란에 동아리 이름 아래 줄로 표시된다.
  final String leaderName;
  final String category;
  final int memberCount;

  /// 로그인한 사용자가 이 동아리에 가입돼 있는지. 홈 피드(myClubsProvider)는
  /// 이게 true인 것만 보여주고, 검색 결과는 가입/미가입을 나눠서 둘 다 보여준다.
  final bool isJoined;

  /// null이면 동아리 사진이 없는 경우다 — ClubListItem이 이때
  /// Assets.clubDefaultThumbnail(기본 썸네일)을 대신 보여준다.
  final String? thumbnailUrl;
  final bool isFavorite;

  ClubModel copyWith({bool? isFavorite}) {
    return ClubModel(
      id: id,
      name: name,
      leaderName: leaderName,
      category: category,
      memberCount: memberCount,
      isJoined: isJoined,
      thumbnailUrl: thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'] as int,
      name: json['name'] as String,
      leaderName: json['leaderName'] as String? ?? '',
      category: json['category'] as String,
      memberCount: json['memberCount'] as int,
      isJoined: json['joined'] as bool? ?? true,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFavorite: json['favorite'] as bool? ?? false,
    );
  }
}
