import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/di_providers.dart';

const _grayText = Color(0xFF8B8B8B);
const _blue = Color(0xFF31C1FF);

/// "스터디 관리" 화면의 "출석번호 확인" 메뉴가 여는 화면
/// (GET /clubs/{clubId}/attendance/code). 동아리장만 볼 수 있다 — 서버가
/// 동아리장이 아니면 403 NOT_CLUB_LEADER를 내려주고, 이 화면은 그 경우도
/// 다른 에러와 마찬가지로 안내 문구로 보여준다(진입 경로 자체가 스터디
/// 관리 화면이라 실제로는 항상 동아리장만 들어온다).
///
/// 오늘 이미 발급된 번호가 있으면 그대로, 없으면 서버가 새로 발급해서
/// 내려준다(멱등) — 이 화면은 발급 자체를 조회 한 번으로 처리하고, 별도의
/// "발급하기" 버튼은 없다. 당겨서 새로고침하면 자정이 지나 날짜가 바뀐
/// 경우 새 번호로 갱신된다.
class StudyAttendanceCodePage extends ConsumerWidget {
  const StudyAttendanceCodePage({super.key, required this.clubId});

  final int clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeAsync = ref.watch(todayAttendanceCodeProvider(clubId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '출석번호 확인',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayAttendanceCodeProvider(clubId));
            await ref.read(todayAttendanceCodeProvider(clubId).future);
          },
          child: codeAsync.when(
            data: (attendanceCode) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: [
                Text(
                  '${attendanceCode.date.month}월 ${attendanceCode.date.day}일 오늘의 출석번호',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: _grayText, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    attendanceCode.code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '멤버들에게 이 번호를 알려주면, "출석 하기" 화면에서 이 번호를\n입력해 오늘 출석을 기록할 수 있어요.\n번호는 오늘 하루 동안 그대로 유지돼요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _grayText, height: 1.5),
                ),
              ],
            ),
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: [
                Text(
                  '출석번호를 불러오지 못했어요: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _grayText, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
