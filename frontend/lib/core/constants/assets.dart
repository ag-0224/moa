/// 정적 에셋 경로 상수.
/// TechTalk(core/constants/assets.dart)처럼 코드 생성 도구로 관리할 수도 있지만,
/// 현재 MOA는 에셋이 로고 하나뿐이라 build_runner 없이 직접 작성한다. 에셋이
/// 늘어나면 그때 코드 생성 도입을 검토한다.
class Assets {
  Assets._();

  static const String logo = 'assets/default_logo.svg';

  /// TechTalk(assets/icons/google_logo.svg)에서 그대로 가져온 구글 로고.
  static const String iconsGoogleLogo = 'assets/icons/google_logo.svg';
}
