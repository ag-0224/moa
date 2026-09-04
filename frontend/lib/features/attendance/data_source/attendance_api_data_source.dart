import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../../../core/network/api_exception.dart';
import '../models/attendance_code_model.dart';
import '../models/attendance_exceptions.dart';
import '../models/my_study_info_model.dart';
import '../models/study_attendance_overview_model.dart';
import 'attendance_data_source.dart';

/// openapi.yaml의 GET /clubs/{clubId}/attendance/overview, POST .../check-in,
/// POST .../vacation, GET .../me 계약과 매핑되는 실제 구현체
/// (docs/API_CONTRACT.md "5. 스터디 출석" 참고).
final class AttendanceApiDataSourceImpl implements AttendanceDataSource {
  AttendanceApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<StudyAttendanceOverviewModel> getOverview(int clubId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/$clubId/attendance/overview');
      return ApiEnvelope.unwrap(response.data, StudyAttendanceOverviewModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<void> checkIn(int clubId, String code) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/clubs/$clubId/attendance/check-in',
        data: {'code': code},
      );
    } on DioException catch (e) {
      final mapped = ApiEnvelope.mapError(e);
      if (mapped is ApiException && mapped.code == 'INVALID_ATTENDANCE_CODE') {
        throw const InvalidAttendanceCodeException();
      }
      if (mapped is ApiException && mapped.code == 'ATTENDANCE_CODE_NOT_ISSUED') {
        throw const AttendanceCodeNotIssuedException();
      }
      throw mapped;
    }
  }

  @override
  Future<void> useVacation(int clubId) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>('/clubs/$clubId/attendance/vacation');
    } on DioException catch (e) {
      final mapped = ApiEnvelope.mapError(e);
      if (mapped is ApiException && mapped.code == 'VACATION_LIMIT_EXCEEDED') {
        throw const VacationLimitExceededException();
      }
      throw mapped;
    }
  }

  @override
  Future<MyStudyInfoModel> getMyMonthlyInfo(int clubId, DateTime month) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/clubs/$clubId/attendance/me',
        queryParameters: {'year': month.year, 'month': month.month},
      );
      return ApiEnvelope.unwrap(response.data, MyStudyInfoModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<AttendanceCodeModel> getTodayCode(int clubId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/clubs/$clubId/attendance/code');
      return ApiEnvelope.unwrap(response.data, AttendanceCodeModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }
}
