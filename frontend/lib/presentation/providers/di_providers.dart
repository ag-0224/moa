import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../features/auth/data_source/auth_api_data_source.dart';
import '../../features/auth/data_source/firebase_auth_data_source.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/auth_repository_impl.dart';
import '../../features/auth/usecases/sign_in_use_case.dart';
import '../../features/auth/usecases/sign_out_use_case.dart';
import '../../features/attendance/data_source/attendance_data_source.dart';
import '../../features/attendance/data_source/attendance_api_data_source.dart';
import '../../features/attendance/models/study_attendance_overview_model.dart';
import '../../features/attendance/repositories/attendance_repository.dart';
import '../../features/attendance/repositories/attendance_repository_impl.dart';
import '../../features/attendance/usecases/get_study_attendance_overview_use_case.dart';
import '../../features/attendance/usecases/check_in_use_case.dart';
import '../../features/attendance/usecases/use_vacation_use_case.dart';
import '../../features/attendance/usecases/get_my_study_info_use_case.dart';
import '../../features/attendance/usecases/get_today_attendance_code_use_case.dart';
import '../../features/attendance/models/attendance_code_model.dart';
import '../../features/attendance/models/my_study_info_model.dart';
import '../../features/club/data_source/club_api_data_source.dart';
import '../../features/club/data_source/club_data_source.dart';
import '../../features/club/models/club_application_model.dart';
import '../../features/club/models/club_detail_model.dart';
import '../../features/club/models/club_member_model.dart';
import '../../features/club/models/club_model.dart';
import '../../features/club/repositories/club_repository.dart';
import '../../features/club/repositories/club_repository_impl.dart';
import '../../features/club/usecases/apply_to_club_use_case.dart';
import '../../features/club/usecases/approve_club_application_use_case.dart';
import '../../features/club/usecases/create_club_use_case.dart';
import '../../features/club/usecases/delete_club_use_case.dart';
import '../../features/club/usecases/update_club_use_case.dart';
import '../../features/club/usecases/get_all_clubs_use_case.dart';
import '../../features/club/usecases/get_club_detail_use_case.dart';
import '../../features/club/usecases/get_club_members_use_case.dart';
import '../../features/club/usecases/get_my_clubs_use_case.dart';
import '../../features/club/usecases/get_pending_club_applications_use_case.dart';
import '../../features/club/usecases/reject_club_application_use_case.dart';
import '../../features/club/usecases/set_club_favorite_use_case.dart';
import '../../features/club/usecases/transfer_club_leadership_use_case.dart';
import '../../features/health/data_source/health_api_data_source.dart';
import '../../features/health/repositories/health_repository.dart';
import '../../features/health/repositories/health_repository_impl.dart';
import '../../features/health/usecases/check_health_use_case.dart';
import '../../features/user/data_source/user_api_data_source.dart';
import '../../features/user/repositories/user_repository.dart';
import '../../features/user/repositories/user_repository_impl.dart';
import '../../features/user/usecases/complete_profile_use_case.dart';
import '../../features/user/usecases/delete_account_use_case.dart';
import '../../features/user/usecases/get_my_info_use_case.dart';

/// Riverpod을 DI 컨테이너로 사용한다 (get_it 등 별도 서비스 로케이터 없음).
/// 계층 의존 방향: presentation -> features/*/usecases -> repositories -> data_source
/// (docs/REPOSITORY_STRUCTURE.md 참고).

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl();
});

final authApiDataSourceProvider = Provider<AuthApiDataSource>((ref) {
  return AuthApiDataSourceImpl(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthDataSourceProvider),
    ref.watch(authApiDataSourceProvider),
    ref.watch(tokenStorageProvider),
  );
});

final signInUseCaseProvider = Provider((ref) => SignInUseCase(ref.watch(authRepositoryProvider)));

final signOutUseCaseProvider = Provider((ref) => SignOutUseCase(ref.watch(authRepositoryProvider)));

final userApiDataSourceProvider = Provider<UserApiDataSource>((ref) {
  return UserApiDataSourceImpl(ref.watch(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userApiDataSourceProvider));
});

final getMyInfoUseCaseProvider = Provider((ref) => GetMyInfoUseCase(ref.watch(userRepositoryProvider)));

final completeProfileUseCaseProvider =
    Provider((ref) => CompleteProfileUseCase(ref.watch(userRepositoryProvider)));

final deleteAccountUseCaseProvider =
    Provider((ref) => DeleteAccountUseCase(ref.watch(userRepositoryProvider)));

final healthApiDataSourceProvider = Provider<HealthApiDataSource>((ref) {
  return HealthApiDataSourceImpl(ref.watch(apiClientProvider));
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl(ref.watch(healthApiDataSourceProvider));
});

final checkHealthUseCaseProvider = Provider((ref) => CheckHealthUseCase(ref.watch(healthRepositoryProvider)));

final clubDataSourceProvider = Provider<ClubDataSource>((ref) {
  return ClubApiDataSourceImpl(ref.watch(apiClientProvider));
});

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepositoryImpl(ref.watch(clubDataSourceProvider));
});

final getMyClubsUseCaseProvider = Provider((ref) => GetMyClubsUseCase(ref.watch(clubRepositoryProvider)));

final getAllClubsUseCaseProvider = Provider((ref) => GetAllClubsUseCase(ref.watch(clubRepositoryProvider)));

final setClubFavoriteUseCaseProvider =
    Provider((ref) => SetClubFavoriteUseCase(ref.watch(clubRepositoryProvider)));

final getClubDetailUseCaseProvider =
    Provider((ref) => GetClubDetailUseCase(ref.watch(clubRepositoryProvider)));

final applyToClubUseCaseProvider =
    Provider((ref) => ApplyToClubUseCase(ref.watch(clubRepositoryProvider)));

/// 메인 페이지 "스터디 등록" 버튼 → 등록 화면(ClubRegisterPage)이 쓰는 유스케이스.
final createClubUseCaseProvider =
    Provider((ref) => CreateClubUseCase(ref.watch(clubRepositoryProvider)));

/// 스터디 관리 페이지 "스터디 정보 수정" 화면(StudyEditPage)이 쓰는 유스케이스.
final updateClubUseCaseProvider =
    Provider((ref) => UpdateClubUseCase(ref.watch(clubRepositoryProvider)));

/// 스터디 관리 페이지 "스터디 삭제" 확인 다이얼로그가 쓰는 유스케이스.
final deleteClubUseCaseProvider =
    Provider((ref) => DeleteClubUseCase(ref.watch(clubRepositoryProvider)));

/// 메인 페이지(홈 피드)가 watch하는 "내가 속한(가입한) 동아리 목록".
final myClubsProvider = FutureProvider<List<ClubModel>>((ref) {
  return ref.watch(getMyClubsUseCaseProvider)();
});

/// 검색 화면이 watch하는 "가입 여부와 상관없는 전체 동아리 목록".
final allClubsProvider = FutureProvider<List<ClubModel>>((ref) {
  return ref.watch(getAllClubsUseCaseProvider)();
});

/// 동아리 상세(가입 전 소개/지원) 화면이 watch하는 단건 조회. clubId별로
/// 캐시되고, 지원 후에는 ref.invalidate(clubDetailProvider(clubId))로 다시
/// 불러와서 applicationStatus 변경을 반영한다.
final clubDetailProvider = FutureProvider.family<ClubDetailModel, int>((ref, clubId) {
  return ref.watch(getClubDetailUseCaseProvider)(clubId);
});

/// 관리자 권한 넘기기 화면(TransferLeadershipPage)이 쓰는 유스케이스.
final getClubMembersUseCaseProvider =
    Provider((ref) => GetClubMembersUseCase(ref.watch(clubRepositoryProvider)));

final transferClubLeadershipUseCaseProvider =
    Provider((ref) => TransferClubLeadershipUseCase(ref.watch(clubRepositoryProvider)));

/// 가입 신청 관리 화면(ClubApplicationsPage)이 쓰는 유스케이스들.
final getPendingClubApplicationsUseCaseProvider =
    Provider((ref) => GetPendingClubApplicationsUseCase(ref.watch(clubRepositoryProvider)));

final approveClubApplicationUseCaseProvider =
    Provider((ref) => ApproveClubApplicationUseCase(ref.watch(clubRepositoryProvider)));

final rejectClubApplicationUseCaseProvider =
    Provider((ref) => RejectClubApplicationUseCase(ref.watch(clubRepositoryProvider)));

/// 관리자 권한 넘기기 화면이 watch하는 clubId별 멤버 목록.
final clubMembersProvider = FutureProvider.family<List<ClubMemberModel>, int>((ref, clubId) {
  return ref.watch(getClubMembersUseCaseProvider)(clubId);
});

/// 가입 신청 관리 화면이 watch하는 clubId별 대기 중인 신청서 목록. 승인/거절
/// 후에는 ref.invalidate(pendingClubApplicationsProvider(clubId))로 다시
/// 불러온다.
final pendingClubApplicationsProvider = FutureProvider.family<List<ClubApplicationModel>, int>((ref, clubId) {
  return ref.watch(getPendingClubApplicationsUseCaseProvider)(clubId);
});

/// 스터디(동아리) 출석 현황 탭 전용 DI. openapi.yaml의 /clubs/{clubId}/attendance/*
/// 계약과 매핑되는 AttendanceApiDataSourceImpl을 쓴다(club feature의
/// ClubDataSource/ClubApiDataSourceImpl과 같은 패턴).
final attendanceDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceApiDataSourceImpl(ref.watch(apiClientProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceDataSourceProvider));
});

final getStudyAttendanceOverviewUseCaseProvider = Provider(
  (ref) => GetStudyAttendanceOverviewUseCase(ref.watch(attendanceRepositoryProvider)),
);

final checkInUseCaseProvider = Provider(
  (ref) => CheckInUseCase(ref.watch(attendanceRepositoryProvider)),
);

final useVacationUseCaseProvider = Provider(
  (ref) => UseVacationUseCase(ref.watch(attendanceRepositoryProvider)),
);

final getMyStudyInfoUseCaseProvider = Provider(
  (ref) => GetMyStudyInfoUseCase(ref.watch(attendanceRepositoryProvider)),
);

/// 스터디 관리 페이지 "출석번호 확인" 화면(StudyAttendanceCodePage)이 쓰는 유스케이스.
final getTodayAttendanceCodeUseCaseProvider = Provider(
  (ref) => GetTodayAttendanceCodeUseCase(ref.watch(attendanceRepositoryProvider)),
);

/// 스터디 홈 화면의 "내 정보" 탭이 watch하는 (clubId, 조회할 달)별 월간
/// 출석/휴가 정보. 화살표나 달력으로 다른 달/연도를 선택하면 month가
/// 바뀌면서 새로운 FutureProvider 인스턴스로 자동 캐시된다.
final myStudyInfoProvider =
    FutureProvider.family<MyStudyInfoModel, ({int clubId, DateTime month})>((ref, params) {
  return ref.watch(getMyStudyInfoUseCaseProvider)(params.clubId, params.month);
});

/// 스터디 홈 화면의 출석 현황 탭이 watch하는 clubId별 출석 개요.
final studyAttendanceOverviewProvider =
    FutureProvider.family<StudyAttendanceOverviewModel, int>((ref, clubId) {
  return ref.watch(getStudyAttendanceOverviewUseCaseProvider)(clubId);
});

/// 스터디 관리 페이지 "출석번호 확인" 화면이 watch하는 clubId별 오늘의
/// 출석번호. 동아리장이 아니면 서버가 403 NOT_CLUB_LEADER를 내려준다.
final todayAttendanceCodeProvider = FutureProvider.family<AttendanceCodeModel, int>((ref, clubId) {
  return ref.watch(getTodayAttendanceCodeUseCaseProvider)(clubId);
});
