/// 정적 에셋 경로 상수.
/// TechTalk(core/constants/assets.dart)처럼 코드 생성 도구로 관리할 수도 있지만,
/// 현재 MOA는 에셋이 로고 하나뿐이라 build_runner 없이 직접 작성한다. 에셋이
/// 늘어나면 그때 코드 생성 도입을 검토한다.
class Assets {
  Assets._();

  static const String logo = 'assets/default_logo.svg';

  /// TechTalk(assets/icons/google_logo.svg)에서 그대로 가져온 구글 로고.
  static const String iconsGoogleLogo = 'assets/icons/google_logo.svg';

  /// 메인 페이지 하단 탭 바 아이콘 (Figma node-id 3073-49, majesticons 세트).
  static const String iconsHome = 'assets/icons/majesticons_home.svg';
  static const String iconsAnalytics = 'assets/icons/majesticons_analytics-line.svg';
  static const String iconsUser = 'assets/icons/majesticons_user-line.svg';

  /// 메인 페이지 상단 헤더 아이콘.
  static const String iconsSearch = 'assets/icons/majesticons_search.svg';
  static const String iconsBell = 'assets/icons/cil_bell.svg';
}
