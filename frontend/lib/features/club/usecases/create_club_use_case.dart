import 'dart:io';

import '../models/club_detail_model.dart';
import '../repositories/club_repository.dart';

/// 메인 페이지 "스터디 등록" 버튼 → 등록 화면(ClubRegisterPage)의 "작성완료"가
/// 호출하는 유스케이스.
class CreateClubUseCase {
  const CreateClubUseCase(this._clubRepository);

  final ClubRepository _clubRepository;

  Future<ClubDetailModel> call({
    required String name,
    required String description,
    File? thumbnail,
  }) =>
      _clubRepository.createClub(name: name, description: description, thumbnail: thumbnail);
}
