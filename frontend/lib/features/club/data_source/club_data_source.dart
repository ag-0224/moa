import 'dart:io';

import '../models/club_application_model.dart';
import '../models/club_detail_model.dart';
import '../models/club_member_model.dart';
import '../models/club_model.dart';

abstract interface class ClubDataSource {
  /// 로그인한 사용자가 소속된(가입된) 동아리 목록.
  Future<List<ClubModel>> getMyClubs();

  /// 가입 여부와 상관없이 전체 동아리 목록. 검색에서 가입/미가입을 나눠
  /// 보여주기 위해 쓴다.
  Future<List<ClubModel>> getAllClubs();

  /// 동아리 하나의 즐겨찾기 여부를 바꾼다.
  Future<void> setFavorite(int clubId, bool isFavorite);

  /// 동아리 상세(가입 전 소개/지원) 화면에서 쓰는 단건 조회.
  Future<ClubDetailModel> getClubDetail(int clubId);

  /// 동아리 상세 화면의 "지원 하기" 버튼이 호출하는 가입 신청.
  Future<ClubDetailModel> applyToClub(int clubId, String selfIntroduction);

  /// 메인 페이지 "스터디 등록" 버튼 → 등록 화면의 "작성완료" 제출.
  /// thumbnail이 null이면 사진을 등록하지 않은 것이다(기본 placeholder 이미지로 대체됨).
  Future<ClubDetailModel> createClub({
    required String name,
    required String description,
    File? thumbnail,
  });

  /// 스터디 관리 페이지의 "스터디 정보 수정". 동아리장만 호출할 수 있다.
  /// thumbnail이 null이면 기존 사진을 그대로 유지한다.
  Future<ClubDetailModel> updateClub({
    required int clubId,
    required String name,
    required String description,
    File? thumbnail,
  });

  /// 스터디 관리 페이지의 "스터디 삭제". 동아리장만 호출할 수 있다.
  Future<void> deleteClub(int clubId);

  /// 관리자 권한 넘기기 화면(멤버 선택)이 쓰는 동아리 멤버 목록.
  Future<List<ClubMemberModel>> getClubMembers(int clubId);

  /// 관리자(동아리장) 권한을 다른 가입 멤버에게 넘긴다. 현재 동아리장만
  /// 호출할 수 있다.
  Future<ClubDetailModel> transferLeadership(int clubId, int newLeaderId);

  /// 가입 신청 관리 화면의 대기 중인 신청서 목록(관리자 전용).
  Future<List<ClubApplicationModel>> getPendingApplications(int clubId);

  /// 가입 신청 승인(관리자 전용).
  Future<ClubApplicationModel> approveApplication(int clubId, int applicationId);

  /// 가입 신청 거절(관리자 전용).
  Future<ClubApplicationModel> rejectApplication(int clubId, int applicationId);
}
