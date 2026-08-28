import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../features/user/models/user_model.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/di_providers.dart';
import '../../widgets/common/button/app_rounded_button.dart';
import '../../widgets/common/input/app_text_field.dart';

/// 마이페이지('내 정보')의 '개인정보 수정'에서 여는 화면.
///
/// 회원가입 화면(sign_up_page.dart)과 필드 구성(이름/닉네임/이메일(읽기전용)/
/// 전공/학번)·스타일을 그대로 재사용한다. 서버 쪽도 "최초 작성"과 "수정"을
/// 구분하지 않고 같은 PATCH /users/me를 쓰므로, 프론트도 같은
/// completeProfileUseCaseProvider를 그대로 호출한다 — 다른 점은 각 필드를
/// 현재 값으로 미리 채워두는 것과, 버튼 문구('저장')뿐이다.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _majorController;
  late final TextEditingController _studentIdController;

  bool _isSubmitting = false;
  String? _nameError;
  String? _nicknameError;
  String? _majorError;
  String? _studentIdError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _nicknameController = TextEditingController(text: widget.user.nickname ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _majorController = TextEditingController(text: widget.user.major ?? '');
    _studentIdController = TextEditingController(text: widget.user.studentId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  static final _digitsOnly = RegExp(r'^[0-9]+$');

  String? _validateStudentId(String studentId) {
    if (studentId.isEmpty) {
      return '학번은 필수 입력 사항이에요.';
    }
    if (!_digitsOnly.hasMatch(studentId)) {
      return '학번은 숫자만 입력할 수 있어요.';
    }
    return null;
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final major = _majorController.text.trim();
    final studentId = _studentIdController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? '이름은 필수 입력 사항이에요.' : null;
      _nicknameError = nickname.isEmpty ? '닉네임은 필수 입력 사항이에요.' : null;
      _majorError = major.isEmpty ? '전공은 필수 입력 사항이에요.' : null;
      _studentIdError = _validateStudentId(studentId);
    });

    if (_nameError != null || _nicknameError != null || _majorError != null || _studentIdError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref.read(completeProfileUseCaseProvider).call(
          name: name,
          nickname: nickname,
          major: major,
          studentId: studentId,
        );

    if (!mounted) return;

    result.when(
      success: (user) {
        // AuthController의 전역 사용자 정보도 갱신해서, 이 화면을 나가면
        // 마이페이지가 바로 최신 이름/닉네임을 보여주게 한다.
        ref.read(authControllerProvider.notifier).markProfileCompleted(user);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장했어요.')));
        Navigator.of(context).pop();
      },
      failure: (error) {
        setState(() {
          _isSubmitting = false;
          if (error is ApiException && error.code == 'DUPLICATE_NICKNAME') {
            _nicknameError = '이미 사용 중인 닉네임이에요.';
          } else if (error is ApiException) {
            _nicknameError = error.message;
          } else {
            _nicknameError = error.toString();
          }
        });
      },
    );
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
          '개인정보 수정',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: '이름',
                hintText: '이름을 입력해주세요',
                icon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
              ),
              AppTextField(
                label: '닉네임',
                hintText: '닉네임을 입력해주세요',
                icon: Icons.explore_outlined,
                controller: _nicknameController,
                errorText: _nicknameError,
              ),
              AppTextField(
                label: '이메일',
                hintText: '이메일을 입력해주세요',
                icon: Icons.mail_outline,
                controller: _emailController,
                enabled: false,
              ),
              AppTextField(
                label: '전공',
                hintText: '전공을 입력해주세요',
                icon: Icons.school_outlined,
                controller: _majorController,
                errorText: _majorError,
              ),
              AppTextField(
                label: '학번',
                hintText: '학번을 입력해주세요',
                icon: Icons.menu_book_outlined,
                controller: _studentIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _studentIdError,
              ),
              const SizedBox(height: 8),
              AppRoundedButton(
                onPressed: _submit,
                isLoading: _isSubmitting,
                backgroundColor: const Color(0xFF31C1FF),
                foregroundColor: Colors.white,
                child: const Text(
                  '저장',
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
