import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/attendance/models/attendance_mark.dart';
import '../../../../features/attendance/models/study_attendance_overview_model.dart';
import '../../../providers/di_providers.dart';
import '../../../widgets/common/button/app_rounded_button.dart';

/// 출석현황 탭 위에 떠 있는 "출석하기" 버튼.
///
/// club_detail_page.dart의 _ApplyButton(지원 하기 버튼)과 똑같이
/// AppRoundedButton을 그대로 쓰고, 색·글자 스타일과 "상태별로 다른 모습을
/// 보여주는" 구조까지 동일하게 맞췄다:
/// - 오늘 이미 출석했으면(overview.myTodayMark == present) _ApplyButton의
///   "이미 가입된 동아리예요"와 같은 비활성 회색 버튼으로 "오늘 출석을
///   완료했어요"를 보여준다.
/// - 아직이면 _ApplyButton의 "지원 하기"와 같은 파란 버튼으로 "출석 하기"를
///   보여주고, 누르면 CheckInUseCase 호출 후 목록을 새로고침한다.
///
/// 화면에 배치할 때는(study_attendance_tab.dart) Stack + Positioned로
/// 리스트 위에 떠 있게(floating) 만든다 — 요청사항.
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

  Future<void> _checkIn() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(checkInUseCaseProvider)(widget.clubId);
      ref.invalidate(studyAttendanceOverviewProvider(widget.clubId));
      await ref.read(studyAttendanceOverviewProvider(widget.clubId).future);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.overview.myTodayMark == AttendanceMark.present) {
      return const AppRoundedButton(
        onPressed: null,
        backgroundColor: _disabledBackground,
        foregroundColor: Colors.black54,
        child: Text('오늘 출석을 완료했어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
    }

    return AppRoundedButton(
      onPressed: _checkIn,
      isLoading: _isSubmitting,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      // sign_up_page.dart '작성 완료'/_ApplyButton '지원 하기'와 같은 글자 스타일.
      child: const Text('출석 하기', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}
