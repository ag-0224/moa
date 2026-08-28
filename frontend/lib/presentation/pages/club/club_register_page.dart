import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../providers/di_providers.dart';
import '../../widgets/common/button/app_rounded_button.dart';
import '../../widgets/common/input/app_text_field.dart';

/// 메인 페이지 "스터디 등록" 플로팅 버튼(team_register_button.dart, 문구는
/// '스터디 등록')을 누르면 이동하는 등록 화면.
///
/// 디자인은 club_apply_page.dart를 그대로 따른다 — 흰 배경 AppBar(뒤로가기 +
/// 가운데 정렬 타이틀), 둥근 모서리(16) 입력창(평소 회색 테두리 / 포커스 시
/// 파란 테두리 / 에러 시 빨간 테두리), 파란 배경의 큰 CTA 버튼.
///
/// "작성완료" 버튼 위치도 club_apply_page.dart의 "지원서 제출" 버튼과 똑같은
/// 자리에 오도록, 레이아웃 구조 자체를 그대로 따라 했다 — 스크롤 뷰 없이
/// Column + Expanded(설명 입력창)로 남는 세로 공간을 전부 채우고, 그 아래
/// (에러 텍스트 → SizedBox 20 → 버튼 → SizedBox 24 → 로딩 자리 → SizedBox 16)
/// 순서의 '바닥 여백 구성'을 apply 화면과 완전히 동일한 값으로 맞췄다. 이
/// 구조 덕분에 버튼과 화면 하단 사이 거리가 두 화면에서 픽셀 단위로 같다.
///
/// 백엔드는 이 "스터디"를 별도 도메인이 아니라 기존 Club 엔티티로 그대로
/// 저장한다 — 이 앱에서는 동아리/스터디/팀이 전부 같은 개념이다(UI 문구만
/// 화면마다 다르게 쓰인다). 성공하면 true를 pop해서 home_page.dart가
/// 목록(myClubsProvider/allClubsProvider)을 새로고침하게 한다.
class ClubRegisterPage extends ConsumerStatefulWidget {
  const ClubRegisterPage({super.key});

  @override
  ConsumerState<ClubRegisterPage> createState() => _ClubRegisterPageState();
}

class _ClubRegisterPageState extends ConsumerState<ClubRegisterPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _thumbnail;
  bool _isSubmitting = false;
  String? _nameError;
  String? _descriptionError;

  static const Color _blue = Color(0xFF31C1FF);
  static const Color _borderColor = Color(0xFF8B8B8B);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _thumbnail = File(picked.path));
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? '스터디 이름을 입력해주세요.' : null;
      _descriptionError = description.isEmpty ? '스터디 소개를 입력해주세요.' : null;
    });

    if (_nameError != null || _descriptionError != null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(createClubUseCaseProvider)(
        name: name,
        description: description,
        thumbnail: _thumbnail,
      );
      if (!mounted) return;

      // 새로 만든 스터디가 홈 피드/검색 목록에 바로 보이도록 새로고침한다
      // (favorite_action_sheet 처리 후 _HomeFeedTabState가 하는 것과 같은 패턴).
      ref.invalidate(myClubsProvider);
      ref.invalidate(allClubsProvider);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('스터디를 등록했어요.')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        // 이름 중복(DUPLICATE_CLUB_NAME)/형식 오류(INVALID_CLUB_NAME) 모두
        // "스터디 이름" 입력칸 아래 빨간 글씨로 보여준다 — 둘 다 이름 때문에
        // 나는 에러라 사용자 입장에서는 구분할 필요가 없다.
        if (e is ApiException) {
          _nameError = e.message;
        } else {
          _nameError = '스터디 등록에 실패했어요: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '스터디 등록',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      // club_apply_page.dart와 완전히 같은 구조: 스크롤 없는 Padding(가로 32만) +
      // Column. 설명 입력창을 Expanded로 감싸 남는 세로 공간을 전부 채우고,
      // 그 아래 버튼까지의 여백 구성(SizedBox 20/24/16 + 로딩 자리)을 apply
      // 화면과 값 하나하나 동일하게 맞춰서, 버튼이 화면 하단으로부터 같은
      // 거리에 오게 했다.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(child: _ThumbnailPicker(image: _thumbnail, onTap: _pickThumbnail)),
              const SizedBox(height: 20),
              AppTextField(
                label: '스터디 이름',
                hintText: '스터디 이름을 입력해주세요',
                icon: Icons.groups_outlined,
                controller: _nameController,
                errorText: _nameError,
              ),
              const Text(
                '스터디 소개',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _borderColor),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '스터디를 간단히 소개해주세요.',
                    hintStyle: const TextStyle(fontSize: 14, color: _borderColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _descriptionError != null ? Colors.red : _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _descriptionError != null ? Colors.red : _borderColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: _blue),
                    ),
                  ),
                ),
              ),
              if (_descriptionError != null) ...[
                const SizedBox(height: 8),
                Text(_descriptionError!, style: const TextStyle(fontSize: 14, color: Colors.red)),
              ],
              const SizedBox(height: 20),
              AppRoundedButton(
                onPressed: _submit,
                isLoading: _isSubmitting,
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                child: const Text(
                  '작성완료',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 24,
                child: _isSubmitting
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// 스터디 사진(placeholder) 선택 버튼. 아직 고르지 않았으면 카메라 아이콘 +
/// "사진 등록" 안내 문구를, 골랐으면 그 사진 미리보기를 보여준다.
class _ThumbnailPicker extends StatelessWidget {
  const _ThumbnailPicker({required this.image, required this.onTap});

  final File? image;
  final VoidCallback onTap;

  static const Color _borderColor = Color(0xFF8B8B8B);
  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Image.file(image!, fit: BoxFit.cover, width: _size, height: _size)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: _borderColor, size: 24),
                  SizedBox(height: 4),
                  Text('사진 등록', style: TextStyle(fontSize: 11, color: _borderColor)),
                ],
              ),
      ),
    );
  }
}
