import 'club_application_status.dart';

/// 동아리 상세(가입 전 소개/지원) 화면 전용 모델. 목록용 ClubModel과 달리
/// description과 applicationStatus를 포함한다.
class ClubDetailModel {
  const ClubDetailModel({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.category,
    required this.memberCount,
    required this.isJoined,
    required this.applicationStatus,
    this.description,
    this.thumbnailUrl,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String leaderName;
  final String category;
  final int memberCount;
  final String? description;
  final String? thumbnailUrl;
  final bool isJoined;
  final bool isFavorite;

  /// isJoined가 true면 항상 ClubApplicationStatus.none이다.
  final ClubApplicationStatus applicationStatus;

  factory ClubDetailModel.fromJson(Map<String, dynamic> json) {
    return ClubDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      leaderName: json['leaderName'] as String? ?? '',
      category: json['category'] as String,
      memberCount: json['memberCount'] as int,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isJoined: json['joined'] as bool? ?? false,
      isFavorite: json['favorite'] as bool? ?? false,
      applicationStatus: ClubApplicationStatus.fromJson(json['applicationStatus'] as String?),
    );
  }
}
