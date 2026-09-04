import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/attendance/models/attendance_exceptions.dart';
import '../../../../features/attendance/models/attendance_mark.dart';
import '../../../../features/attendance/models/study_attendance_overview_model.dart';
import '../../../providers/di_providers.dart';
import '../../../widgets/common/button/app_rounded_button.dart';
import '../../../widgets/common/input/app_text_field.dart';

enum _AttendanceMethod { code, vacation }

/// 출석현황 탭 위에 떠 있는 "출석하기" 버튼.
///
/// club_detail_page.dart의 _ApplyButton(지원 하기 버튼)과 똑같이
/// AppRoundedButton을 그대로 쓰고, 색·글자 스타일과 "상태별로 다른 모습을
/// 보여주는" 구조까지 동일하게 맞췄다. 다만 눌렀다고 바로 출석 처리하지 않고
/// (요청사항) 먼저 "출석번호 입력" / "휴가 사용" 중 하나를 고르게 한다:
/// - 출석번호 입력: 오늘의 출석번호(서버 GET .../attendance/overview가 아니라
///   POST .../attendance/check-in이 직접 검증한다)를 맞히면 출석 처리.
/// - 휴가 사용: 이번 학기 남은 휴가가 있으면 확인 후 오늘을 휴가로 처리
///   (결석 아님).
///
/// 오늘 이미 출석했거나 휴가를 썼으면 _ApplyButton의 "이미 가입된
/// 동아리예요"처럼 비활성 회색 버튼으로 상태만 보여준다.
///
/// 화면에 배치할 때는(study_attendance_tab.dart) Stack + Positioned로
/// 리스트 위에 떠 있게(floating) 만든다.
class CheckInButton extends ConsumerStatefulWidget {
  const CheckInButton({super.key, required this.clubId, required this.overview});

  final int clubId;
  final StudyAttendanceOverviewModel overview;

  @override
  ConsumerState<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends ConsumerState<CheckInButton> {
  bool _isSubmitting = false;

  // showDialog는 기본적으로(useRootNavigator: true) 이 버튼이 속한 탭/화면과
  // 무관한 루트 Navigator 위에 다이얼로그를 띄운다. 그래서 다이얼로그가 떠 있는
  // 동안 뒤로가기나 탭 전환으로 이 버튼(과 ref)이 dispose되어도 다이얼로그
  // 자체는 화면에 그대로 남아있을 수 있고, 그 안의 콜백이 죽은 ref/state를
  // 참조하다가 "Looking up a deactivated widget's ancestor"류의 프레임워크
  // assertion으로 이어질 수 있다. 지금 열려 있는 다이얼로그의 context를
  // 기억해뒀다가, 이 위젯이 dispose될 때 같이 닫아서 이런 상황을 막는다.
  BuildContext? _openDialogContext;

  static const Color _blue = Color(0xFF31C1FF);
  static const Color _disabledBackground = Color(0xFFE5E5EA);

  @override
  void dispose() {
    final dialogContext = _openDialogContext;
    if (dialogContext != null && dialogContext.mounted) {
      Navigator.of(dialogContext).pop();
    }
    super.dispose();
  }

  Future<void> _refreshOverview() async {
    ref.invalidate(studyAttendanceOverviewProvider(widget.clubId));
    // "내 정보" 탭의 월별 달력/통계도 오늘 상태를 공유하므로 같이 새로고침한다.
    // 오늘이 바뀌는 건 항상 "이번 달"뿐이라 그 항목만 무효화하면 된다 — 다른
    // 달을 보고 있었더라도 그 달의 캐시된 데이터는 영향받지 않는다.
    final now = DateTime.now();
    ref.invalidate(myStudyInfoProvider((clubId: widget.clubId, month: DateTime(now.year, now.month, 1))));
    await ref.read(studyAttendanceOverviewProvider(widget.clubId).future);
  }

  /// "출석 하기" 버튼을 누르면 가장 먼저 뜨는 선택 다이얼로그.
  Future<void> _startCheckIn() async {
    final method = await showDialog<_AttendanceMethod>(
      context: context,
      builder: (dialogContext) {
        _openDialogContext = dialogContext;
        return AlertDialog(
          title: const Text('출석하기'),
          content: const Text('오늘 출석을 어떻게 처리할까요?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_AttendanceMethod.vacation),
              child: const Text('휴가 사용'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_AttendanceMethod.code),
              child: const Text('출석번호 입력'),
            ),
          ],
        );
      },
    );
    _openDialogContext = null;

    if (!mounted || method == null) return;

    switch (method) {
      case _AttendanceMethod.code:
        await _showCodeDialog();
        break;
      case _AttendanceMethod.vacation:
        await _confirmUseVacation();
        break;
    }
  }

  /// 출석번호를 입력받는 다이얼로그. 틀리면 다이얼로그를 닫지 않고 그 안에서
  /// 바로 에러 메시지를 보여준다(club_apply_page.dart의 제출 실패 처리와
  /// 같은 태도: 화면을 벗어나지 않고 같은 자리에서 다시 시도하게 함).
  Future<void> _showCodeDialog() async {
    final controller = TextEditingController();
    String? errorText;
    var isSubmitting = false;

    final checkedIn = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        _openDialogContext = dialogContext;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              // 다이얼로그가 떠 있는 동안 뒤로가기/탭 전환으로 이 버튼 자체가
              // 이미 dispose됐다면(ref도 함께 죽었으므로) 여기서 멈춘다 —
              // dispose()가 이 다이얼로그를 곧 닫아줄 것이다.
              if (!mounted) return;

              final code = controller.text.trim();
              if (code.length != 4) {
                setDialogState(() => errorText = '출석번호 4자리를 입력해주세요.');
                return;
              }
              setDialogState(() {
                isSubmitting = true;
                errorText = null;
              });
              try {
                await ref.read(checkInUseCaseProvider)(widget.clubId, code);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
              } on InvalidAttendanceCodeException {
                if (!dialogContext.mounted) return;
                setDialogState(() {
                  isSubmitting = false;
                  errorText = '출석번호가 올바르지 않아요.';
                });
              } on AttendanceCodeNotIssuedException {
                if (!dialogContext.mounted) return;
                setDialogState(() {
                  isSubmitting = false;
                  errorText = '아직 오늘의 출석번호가 발급되지 않았어요. 스터디장에게 문의해주세요.';
                });
              }
            }

            return AlertDialog(
              title: const Text('출석번호 입력'),
              content: AppTextField(
                label: '출석번호',
                // 아직 관리자용 "출석번호 확인" 화면이 없어서(별도 이슈,
                // docs/API_CONTRACT.md "5. 스터디 출석" 참고), 로컬 개발
                // DB(data.sql)에 스터디 1번 한정으로 고정 시딩된 테스트용
                // 코드를 힌트로 같이 보여준다. 발급 화면이 생기면 이 힌트는
                // 지운다.
                hintText: '오늘의 출석번호 4자리 (로컬 개발 테스트: 1234)',
                icon: Icons.confirmation_number_outlined,
                controller: controller,
                enabled: !isSubmitting,
                errorText: errorText,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
    _openDialogContext = null;

    controller.dispose();
    if (checkedIn != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await _refreshOverview();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 휴가 사용 확인 다이얼로그. 이번 학기 휴가를 이미 다 썼으면 확인 대신
  /// 안내만 보여준다.
  Future<void> _confirmUseVacation() async {
    final remaining = widget.overview.myVacationDaysTotal - widget.overview.myVacationDaysUsed;

    if (remaining <= 0) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          _openDialogContext = dialogContext;
          return AlertDialog(
            title: const Text('휴가 사용'),
            content: const Text('이번 학기 휴가를 모두 사용했어요.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('확인')),
            ],
          );
        },
      );
      _openDialogContext = null;
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        _openDialogContext = dialogContext;
        return AlertDialog(
          title: const Text('휴가 사용'),
          content: Text(
            '오늘 휴가를 사용하시겠어요? 결석 처리되지 않아요.\n'
            '(사용 시 이번 학기 휴가 ${widget.overview.myVacationDaysUsed + 1}/${widget.overview.myVacationDaysTotal}일 소진)',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('사용하기')),
          ],
        );
      },
    );
    _openDialogContext = null;

    if (confirmed != true || !mounted) return;

    // await 이후에 ScaffoldMessenger.of(context)를 호출하면, 그 사이에 화면을
    // 벗어나 deactivate된 경우 "Looking up a deactivated widget's ancestor is
    // unsafe" 에러가 난다(club_apply_page.dart _submit()과 같은 이유). await
    // 전에 미리 참조를 캡처해두고 그 참조만 사용한다.
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);
    try {
      await ref.read(useVacationUseCaseProvider)(widget.clubId);
      await _refreshOverview();
    } on VacationLimitExceededException {
      // 화면에 표시된 남은 휴가 일수가 오래돼서(다른 기기 등) 서버와 어긋난
      // 경우에 대한 방어다 — 최신 상태를 다시 불러와 보여준다.
      await _refreshOverview();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('이번 학기 휴가를 이미 모두 사용했어요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myMark = widget.overview.myTodayMark;

    if (myMark == AttendanceMark.present) {
      return const AppRoundedButton(
        onPressed: null,
        backgroundColor: _disabledBackground,
        foregroundColor: Colors.black54,
        child: Text('오늘 출석을 완료했어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
    }

    if (myMark == AttendanceMark.vacation) {
      return const AppRoundedButton(
        onPressed: null,
        backgroundColor: _disabledBackground,
        foregroundColor: Colors.black54,
        child: Text('오늘은 휴가를 사용했어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
    }

    return AppRoundedButton(
      onPressed: _isSubmitting ? null : _startCheckIn,
      isLoading: _isSubmitting,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      // sign_up_page.dart '작성 완료'/_ApplyButton '지원 하기'와 같은 글자 스타일.
      child: const Text('출석 하기', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}
