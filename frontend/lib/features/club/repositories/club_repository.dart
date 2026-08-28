import 'dart:io';

import '../models/club_detail_model.dart';
import '../models/club_model.dart';

abstract interface class ClubRepository {
  Future<List<ClubModel>> getMyClubs();

  Future<List<ClubModel>> getAllClubs();

  Future<void> setFavorite(int clubId, bool isFavorite);

  Future<ClubDetailModel> getClubDetail(int clubId);

  Future<ClubDetailModel> applyToClub(int clubId, String selfIntroduction);

  Future<ClubDetailModel> createClub({
    required String name,
    required String description,
    File? thumbnail,
  });
}
