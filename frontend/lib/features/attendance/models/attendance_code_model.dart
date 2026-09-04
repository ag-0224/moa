/// 스터디 관리 페이지의 "출석번호 확인" 화면이 쓰는, 오늘의 4자리 출석번호.
///
/// openapi.yaml의 AttendanceCode 스키마와 매핑된다. date는 이 코드가
/// 유효한 날짜(오늘)다 — 자정을 넘겨서 화면을 계속 보고 있어도 이 모델
/// 자체는 갱신되지 않으므로, 새로고침(ref.invalidate)해야 다음 날짜의
/// 코드로 바뀐다.
class AttendanceCodeModel {
  const AttendanceCodeModel({
    required this.code,
    required this.date,
  });

  final String code;
  final DateTime date;

  factory AttendanceCodeModel.fromJson(Map<String, dynamic> json) {
    return AttendanceCodeModel(
      code: json['code'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
