/// 동아리 하나를 나타내는 모델. 메인 페이지(홈 피드)의 "내가 속한 동아리
/// 목록"과 검색 결과(가입/미가입 동아리 전체)에서 공통으로 쓴다.
///
/// 참고: openapi.yaml/backend에는 아직 동아리 목록 API 계약이 없다(회원가입/로그인
/// 기능까지만 구현됨). 그래서 지금은 ClubMockDataSourceImpl이 목데이터를 돌려주고
/// 있고, 이 모델의 필드는 Figma 목업 화면(node-id 3073-49)에 실제로 표시되는
/// 정보(썸네일, 이름, 대표 이름, 카테고리, 인원수, 즐겨찾기 여부, 가입 여부)만
/// 우선 반영했다. 백엔드 API가 생기면 fromJson을 그 응답 스키마에 맞춰 조정하면
/// 된다.
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
      isJoined: json['isJoined'] as bool? ?? true,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
