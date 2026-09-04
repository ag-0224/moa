import 'dart:io';

import '../models/club_detail_model.dart';
import '../repositories/club_repository.dart';

/// 스터디 관리 페이지 "스터디 정보 수정" 화면(StudyEditPage)이 쓰는 유스케이스.
class UpdateClubUseCase {
  const UpdateClubUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubDetailModel> call({
    required int clubId,
    required String name,
    required String description,
    File? thumbnail,
  }) =>
      _clubRepository.updateClub(clubId: clubId, name: name, description: description, thumbnail: thumbnail);
}
