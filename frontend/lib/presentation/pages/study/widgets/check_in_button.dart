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
/// - 출석번호 입력: 오늘의 출석번호(테스트용 고정값은
///   MockAttendanceDataSource.testAttendanceCode)를 맞히면 출석 처리.
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

  static const Color _blue = Color(0xFF31C1FF);
  static const Color _disabledBackground = Color(0xFFE5E5EA);

  Future<void> _refreshOverview() async {
    ref.invalidate(studyAttendanceOverviewProvider(widget.clubId));
    await ref.read(studyAttendanceOverviewProvider(widget.clubId).future);
  }

  /// "출석 하기" 버튼을 누르면 가장 먼저 뜨는 선택 다이얼로그.
  Future<void> _startCheckIn() async {
    final method = await showDialog<_AttendanceMethod>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
    );

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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
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
                setDialogState(() {
                  isSubmitting = false;
                  errorText = '출석번호가 올바르지 않아요.';
                });
              }
            }

            return AlertDialog(
              title: const Text('출석번호 입력'),
              content: AppTextField(
                label: '출석번호',
                // 아직 관리자용 "출석번호 확인" 화면이 없어서, 테스트 단계에서는
                // 고정된 4자리 코드(MockAttendanceDataSource.testAttendanceCode)를
                // 힌트로 같이 보여준다. 실제 API가 붙으면 이 힌트는 지운다.
                hintText: '오늘의 출석번호 4자리 (테스트: 1234)',
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
        builder: (dialogContext) => AlertDialog(
          title: const Text('휴가 사용'),
          content: const Text('이번 학기 휴가를 모두 사용했어요.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('확인')),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('휴가 사용'),
        content: Text(
          '오늘 휴가를 사용하시겠어요? 결석 처리되지 않아요.\n'
          '(사용 시 이번 학기 휴가 ${widget.overview.myVacationDaysUsed + 1}/${widget.overview.myVacationDaysTotal}일 소진)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('사용하기')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(useVacationUseCaseProvider)(widget.clubId);
      await _refreshOverview();
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
