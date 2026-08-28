import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../features/auth/data_source/auth_api_data_source.dart';
import '../../features/auth/data_source/firebase_auth_data_source.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/auth_repository_impl.dart';
import '../../features/auth/usecases/sign_in_use_case.dart';
import '../../features/auth/usecases/sign_out_use_case.dart';
import '../../features/club/data_source/club_api_data_source.dart';
import '../../features/club/data_source/club_data_source.dart';
import '../../features/club/models/club_detail_model.dart';
import '../../features/club/models/club_model.dart';
import '../../features/club/repositories/club_repository.dart';
import '../../features/club/repositories/club_repository_impl.dart';
import '../../features/club/usecases/apply_to_club_use_case.dart';
import '../../features/club/usecases/get_all_clubs_use_case.dart';
import '../../features/club/usecases/get_club_detail_use_case.dart';
import '../../features/club/usecases/get_my_clubs_use_case.dart';
import '../../features/club/usecases/set_club_favorite_use_case.dart';
import '../../features/health/data_source/health_api_data_source.dart';
import '../../features/health/repositories/health_repository.dart';
import '../../features/health/repositories/health_repository_impl.dart';
import '../../features/health/usecases/check_health_use_case.dart';
import '../../features/user/data_source/user_api_data_source.dart';
import '../../features/user/repositories/user_repository.dart';
import '../../features/user/repositories/user_repository_impl.dart';
import '../../features/user/usecases/complete_profile_use_case.dart';
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
