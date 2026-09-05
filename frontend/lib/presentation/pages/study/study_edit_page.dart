import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/assets.dart';
import '../../../core/network/api_exception.dart';
import '../../../features/club/models/club_detail_model.dart';
import '../../providers/di_providers.dart';
import '../../widgets/common/button/app_rounded_button.dart';
import '../../widgets/common/input/app_text_field.dart';

const _blue = Color(0xFF31C1FF);
const _borderColor = Color(0xFF8B8B8B);

/// "스터디 관리" 화면의 "스터디 정보 수정" 메뉴가 여는 화면
/// (PATCH /clubs/{clubId}).
///
/// club_register_page.dart(스터디 등록)와 같은 디자인/입력창 구성을 그대로
/// 따르되, 기존 이름/소개/사진으로 미리 채워서 보여준다는 점만 다르다.
/// StudyManagementPage가 전달받는 ClubModel에는 description이 없어서
/// (목록용 모델이라 상세 화면 전용 필드가 빠져 있다 — club_model.dart 참고),
/// clubDetailProvider로 상세를 한 번 더 불러와 그 값으로 폼을 채운다.
class StudyEditPage extends ConsumerWidget {
  const StudyEditPage({super.key, required this.clubId});

  final int clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(clubDetailProvider(clubId));

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
          '스터디 정보 수정',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) => _StudyEditForm(clubId: clubId, initial: detail),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '스터디 정보를 불러오지 못했어요: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _borderColor, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyEditForm extends ConsumerStatefulWidget {
  const _StudyEditForm({required this.clubId, required this.initial});

  final int clubId;
  final ClubDetailModel initial;

  @override
  ConsumerState<_StudyEditForm> createState() => _StudyEditFormState();
}

class _StudyEditFormState extends ConsumerState<_StudyEditForm> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initial.name);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initial.description ?? '');

  /// null이면 "새로 고르지 않았다"는 뜻이다 — 이때는 기존 사진
  /// (widget.initial.thumbnailUrl)을 그대로 유지하도록 요청에 thumbnail
  /// 파트를 아예 보내지 않는다(club_api_data_source.dart updateClub 참고).
  File? _newThumbnail;
  bool _isSubmitting = false;
  String? _nameError;
  String? _descriptionError;

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
      setState(() => _newThumbnail = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_thumbnailErrorMessage(e))),
      );
    }
  }

  // image_picker 네이티브 플러그인이 hot reload/restart만으로는 등록되지
  // 않는 문제에 대한 안내 — club_register_page.dart의 같은 메서드 참고.
  String _thumbnailErrorMessage(Object error) {
    if (error is PlatformException && error.code == 'channel-error') {
      return '사진 기능이 아직 앱에 반영되지 않았어요. 앱을 완전히 종료했다가 다시 실행해주세요.';
    }
    return '사진을 불러오지 못했어요: $error';
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? '스터디 이름을 입력해주세요.' : null;
      _descriptionError = description.isEmpty ? '스터디 소개를 입력해주세요.' : null;
    });

    if (_nameError != null || _descriptionError != null) return;

    setState(() => _isSubmitting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ref.read(updateClubUseCaseProvider)(
        clubId: widget.clubId,
        name: name,
        description: description,
        thumbnail: _newThumbnail,
      );
      if (!mounted) return;

      // 스터디 목록/상세에 보이는 이름·소개·사진을 최신 상태로 갱신한다.
      ref.invalidate(myClubsProvider);
      ref.invalidate(allClubsProvider);
      ref.invalidate(clubDetailProvider(widget.clubId));

      if (messenger.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('스터디 정보를 수정했어요.')));
      }
      // StudyHomePage가 들고 있는 ClubModel 스냅샷(이름 등)은 이 화면 하나만
      // pop해서는 갱신되지 않는다 — TransferLeadershipPage와 같은 이유로,
      // 스터디 관리/스터디 홈을 모두 지나 목록 화면으로 돌아간다.
      if (navigator.mounted) {
        navigator.popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        if (e is ApiException) {
          _nameError = e.message;
        } else {
          _nameError = '스터디 정보 수정에 실패했어요: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _ThumbnailPicker(
              newImage: _newThumbnail,
              existingImageUrl: widget.initial.thumbnailUrl,
              onTap: _pickThumbnail,
            ),
          ),
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
              '저장',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// 스터디 사진 선택 버튼. 새로 고른 사진(newImage)이 있으면 그 미리보기를,
/// 없으면 기존 사진(existingImageUrl)을, 그마저도 없으면 기본 placeholder를
/// 보여준다 — club_register_page.dart의 _ThumbnailPicker와 같은 모양이지만
/// "기존 사진" 상태가 하나 더 있다는 점이 다르다.
class _ThumbnailPicker extends StatelessWidget {
  const _ThumbnailPicker({required this.newImage, required this.existingImageUrl, required this.onTap});

  final File? newImage;
  final String? existingImageUrl;
  final VoidCallback onTap;

  static const double _size = 120;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (newImage != null) {
      content = Image.file(newImage!, fit: BoxFit.cover, width: _size, height: _size);
    } else if (existingImageUrl != null) {
      content = Image.network(existingImageUrl!, fit: BoxFit.cover, width: _size, height: _size);
    } else {
      content = Image.asset(Assets.clubDefaultThumbnail, fit: BoxFit.cover, width: _size, height: _size);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: content,
          ),
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
            child: const Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
