import 'package:flutter/material.dart';

/// MOA 전역에서 반복되는 큰 CTA 버튼(둥근 모서리 16, 높이 60, 로딩 스피너 지원)을
/// 하나로 묶은 공통 컴포넌트.
///
/// TechTalk가 자주 쓰는 버튼을 presentation/widgets/common/button/ 아래에 모아두는
/// 것과 같은 위치·역할이다. GoogleSignInButton(흰 배경 + 테두리),
/// AppleSignInButton(검정 배경), SignUpPage의 '작성 완료' 버튼(파란 배경)이
/// 전부 SizedBox(height: 60, width: double.infinity) + FilledButton/OutlinedButton +
/// RoundedRectangleBorder(16)을 각자 반복해서 만들고 있던 것을 이 위젯 하나로
/// 합쳤다. borderColor를 주면 OutlinedButton(테두리 버튼), 안 주면 FilledButton
/// (단색 버튼)으로 렌더링한다.
class AppRoundedButton extends StatelessWidget {
  const AppRoundedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor = Colors.black,
    this.borderColor,
    this.isLoading = false,
    this.loadingColor = Colors.white,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  /// true면 onPressed를 비활성화하고 child 대신 작은 원형 로딩 인디케이터를 보여준다.
  final bool isLoading;
  final Color loadingColor;

  static const double height = 60;
  static const double borderRadius = 16;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));
    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: loadingColor),
          )
        : child;
    final effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: borderColor != null
          ? OutlinedButton(
              onPressed: effectiveOnPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor ?? Colors.white,
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor!),
                shape: shape,
              ),
              child: content,
            )
          : FilledButton(
              onPressed: effectiveOnPressed,
              style: FilledButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                shape: shape,
              ),
              child: content,
            ),
    );
  }
}
