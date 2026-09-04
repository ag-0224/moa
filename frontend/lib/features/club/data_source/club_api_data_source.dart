import 'dart:io';

import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../models/club_application_model.dart';
import '../models/club_detail_model.dart';
import '../models/club_member_model.dart';
import '../models/club_model.dart';
import 'club_data_source.dart';

/// openapi.yaml의 GET /clubs/me, GET /clubs, POST /clubs, PATCH
/// /clubs/{clubId}/favorite, GET /clubs/{clubId}, POST /clubs/{clubId}/apply,
/// GET /clubs/{clubId}/members, PATCH /clubs/{clubId}/leader, GET/POST
/// /clubs/{clubId}/applications... 계약과 매핑되는 실제 구현체.
final class ClubApiDataSourceImpl implements ClubDataSource {
  ClubApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ClubModel>> getMyClubs() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/me');
      return ApiEnvelope.unwrapList(response.data, ClubModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<List<ClubModel>> getAllClubs() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs');
      return ApiEnvelope.unwrapList(response.data, ClubModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<void> setFavorite(int clubId, bool isFavorite) async {
    try {
      await _apiClient.dio.patch<Map<String, dynamic>>(
        '/clubs/$clubId/favorite',
        data: {'favorite': isFavorite},
      );
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<ClubDetailModel> getClubDetail(int clubId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/$clubId');
      return ApiEnvelope.unwrap(response.data, ClubDetailModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<ClubDetailModel> applyToClub(int clubId, String selfIntroduction) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/clubs/$clubId/apply',
        data: {'selfIntroduction': selfIntroduction},
      );
      return ApiEnvelope.unwrap(response.data, ClubDetailModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  /// POST /clubs는 사진 파일을 함께 받아야 해서 JSON이 아니라
  /// multipart/form-data로 보낸다(백엔드 ClubController#createClub 참고).
  @override
  Future<ClubDetailModel> createClub({
    required String name,
    required String description,
    File? thumbnail,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        if (thumbnail != null) 'thumbnail': await MultipartFile.fromFile(thumbnail.path),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>('/clubs', data: formData);
      return ApiEnvelope.unwrap(response.data, ClubDetailModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<List<ClubMemberModel>> getClubMembers(int clubId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/$clubId/members');
      return ApiEnvelope.unwrapList(response.data, ClubMemberModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<ClubDetailModel> transferLeadership(int clubId, int newLeaderId) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '/clubs/$clubId/leader',
        data: {'newLeaderId': newLeaderId},
      );
      return ApiEnvelope.unwrap(response.data, ClubDetailModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<List<ClubApplicationModel>> getPendingApplications(int clubId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/$clubId/applications');
      return ApiEnvelope.unwrapList(response.data, ClubApplicationModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<ClubApplicationModel> approveApplication(int clubId, int applicationId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/clubs/$clubId/applications/$applicationId/approve',
      );
      return ApiEnvelope.unwrap(response.data, ClubApplicationModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<ClubApplicationModel> rejectApplication(int clubId, int applicationId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/clubs/$clubId/applications/$applicationId/reject',
      );
      return ApiEnvelope.unwrap(response.data, ClubApplicationModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }
}
