import 'dart:io';

import '../data_source/club_data_source.dart';
import '../models/club_application_model.dart';
import '../models/club_detail_model.dart';
import '../models/club_member_model.dart';
import '../models/club_model.dart';
import 'club_repository.dart';

final class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._clubDataSource);

  final ClubDataSource _clubDataSource;

  @override
  Future<List<ClubModel>> getMyClubs() => _clubDataSource.getMyClubs();

  @override
  Future<List<ClubModel>> getAllClubs() => _clubDataSource.getAllClubs();

  @override
  Future<void> setFavorite(int clubId, bool isFavorite) => _clubDataSource.setFavorite(clubId, isFavorite);

  @override
  Future<ClubDetailModel> getClubDetail(int clubId) => _clubDataSource.getClubDetail(clubId);

  @override
  Future<ClubDetailModel> applyToClub(int clubId, String selfIntroduction) =>
      _clubDataSource.applyToClub(clubId, selfIntroduction);

  @override
  Future<ClubDetailModel> createClub({
    required String name,
    required String description,
    File? thumbnail,
  }) =>
      _clubDataSource.createClub(name: name, description: description, thumbnail: thumbnail);

  @override
  Future<List<ClubMemberModel>> getClubMembers(int clubId) => _clubDataSource.getClubMembers(clubId);

  @override
  Future<ClubDetailModel> transferLeadership(int clubId, int newLeaderId) =>
      _clubDataSource.transferLeadership(clubId, newLeaderId);

  @override
  Future<List<ClubApplicationModel>> getPendingApplications(int clubId) =>
      _clubDataSource.getPendingApplications(clubId);

  @override
  Future<ClubApplicationModel> approveApplication(int clubId, int applicationId) =>
      _clubDataSource.approveApplication(clubId, applicationId);

  @override
  Future<ClubApplicationModel> rejectApplication(int clubId, int applicationId) =>
      _clubDataSource.rejectApplication(clubId, applicationId);
}
