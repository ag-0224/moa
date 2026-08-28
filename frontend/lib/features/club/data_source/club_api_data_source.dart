import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../models/club_model.dart';
import 'club_data_source.dart';

/// openapi.yaml의 GET /clubs/me, GET /clubs, PATCH /clubs/{clubId}/favorite
/// 계약과 매핑된다. ClubMockDataSourceImpl을 대체하는 실제 구현체.
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
}
