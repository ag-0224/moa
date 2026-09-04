import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null || !mounted) return;
      setState(() => _thumbnail = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_thumbnailErrorMessage(e))),
      );
    }
  }

  /// image_picker를 pubspec.yaml에 새로 추가한 뒤 앱을 완전히 재시작(정지 후
  /// 다시 실행)하지 않고 hot reload/hot restart만 했을 때 정확히 이 에러가
  /// 난다 — 네이티브 플러그인 등록은 앱 프로세스가 처음 켜질 때 한 번만
  /// 일어나서, 코드/네이티브 프로젝트에 플러그인이 다 들어있어도 지금 떠
  /// 있는 프로세스에는 반영이 안 된 상태이기 때문이다("PlatformException
  /// (channel-error, Unable to establish connection on channel:
  /// dev.flutter.pigeon.image_picker_*.ImagePickerApi.pickImage, ...)"가
  /// 전형적인 신호). 이 경우는 코드를 더 고쳐도 해결되지 않고, 앱을 완전히
  /// 종료했다가(에뮬레이터/시뮬레이터에서 flutter run을 처음부터 다시)
  /// 실행해야 한다.
  String _thumbnailErrorMessage(Object error) {
    if (error is PlatformException && error.code == 'channel-error') {
      return '사진 기능이 아직 앱에 반영되지 않았어요. 앱을 완전히 종료했다가 다시 실행해주세요.';
    }
    return '사진을 불러오지 못했어요: $error';
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

    // await 이후에 ScaffoldMessenger.of(context)/Navigator.of(context)를 호출하면,
    // 그 사이에 사용자가 뒤로가기 등으로 화면을 벗어나 위젯이 deactivate된 경우
    // "Looking up a deactivated widget's ancestor is unsafe" 에러가 난다.
    // mounted 체크만으로는 막을 수 없으므로(디액티베이트된 상태에서도 mounted는
    // true다), await 전에 미리 참조를 캡처해두고 그 참조만 사용한다
    // (club_apply_page.dart의 _submit()과 같은 패턴).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

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

      messenger.showSnackBar(const SnackBar(content: Text('스터디를 등록했어요.')));
      navigator.pop(true);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _ThumbnailPicker(image: _thumbnail, onTap: _pickThumbnail)),
              const SizedBox(height: 28),
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
              SizedBox(
                height: 160,
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
              const SizedBox(height: 24),
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
  static const double _size = 120;

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
                  Icon(Icons.add_a_photo_outlined, color: _borderColor, size: 28),
                  SizedBox(height: 6),
                  Text('사진 등록', style: TextStyle(fontSize: 12, color: _borderColor)),
                ],
              ),
      ),
    );
  }
}
