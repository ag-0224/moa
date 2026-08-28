/// 메인 페이지(홈 피드)에 표시되는 "내가 속한 동아리" 한 건.
///
/// 참고: openapi.yaml/backend에는 아직 동아리 목록 API 계약이 없다(회원가입/로그인
/// 기능까지만 구현됨). 그래서 지금은 ClubMockDataSourceImpl이 목데이터를 돌려주고
/// 있고, 이 모델의 필드는 Figma 목업 화면(node-id 3073-49)에 실제로 표시되는
/// 정보(썸네일, 이름, 카테고리, 인원수, 즐겨찾기 여부)만 우선 반영했다. 백엔드
/// API가 생기면 fromJson을 그 응답 스키마에 맞춰 조정하면 된다.
class ClubModel {
  const ClubModel({
    required this.id,
    required this.name,
    required this.category,
    required this.memberCount,
    this.thumbnailUrl,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String category;
  final int memberCount;

  /// null이면 동아리 사진이 없는 경우다 — ClubListItem이 이때
  /// Assets.clubDefaultThumbnail(기본 썸네일)을 대신 보여준다.
  final String? thumbnailUrl;
  final bool isFavorite;

  ClubModel copyWith({bool? isFavorite}) {
    return ClubModel(
      id: id,
      name: name,
      category: category,
      memberCount: memberCount,
      thumbnailUrl: thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      memberCount: json['memberCount'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
