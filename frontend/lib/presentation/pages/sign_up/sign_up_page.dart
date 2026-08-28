import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../features/user/models/user_model.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/di_providers.dart';
import 'widgets/sign_up_text_field.dart';

/// docs/API_CONTRACT.md의 '회원가입(추가 정보 입력)' 절, Figma 'moa ver 3.0'의
/// '최초 접속자 추가 정보 입력 화면'(node-id 3018:204)을 참고했다.
///
/// AuthController가 로그인/세션 복원 직후 user.profileCompleted가 false이면
/// AuthNeedsSignUp 상태로 전환하고, app.dart가 그 상태일 때 이 화면을 띄운다
/// (백엔드 users 테이블에 nickname이 비어 있으면, 즉 아직 회원가입을 완료하지
/// 않은 사용자면 이 화면으로, 채워져 있으면(=회원 정보가 이미 있으면) 바로
/// 메인 화면으로 보내는 로직).
///
/// TechTalk의 presentation/pages/sign_up/과 같은 위치·역할이지만, TechTalk는
/// hooks_riverpod 기반의 다단계 스텝 마법사(steps/providers/events로 잘게
/// 쪼갠 구조)를 쓰는 반면, MOA의 회원가입은 Figma 디자인상 한 화면에 모든
/// 입력을 받는 단일 폼이라 그 정도 복잡한 구조가 필요 없어 일반적인
/// ConsumerStatefulWidget 폼으로 구현했다.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
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
    // 구글/애플 로그인 정보의 이름은 실명이 아닌 경우가 많고(예: 영문 표시 이름),
    // MOA에서 쓸 실제 이름은 사용자가 직접 입력해야 하므로 비워둔다. 대신 그 값을
    // 닉네임 칸에 기본값으로 채워 넣어(로그인 정보 기반 자동기입) 매번 처음부터
    // 타이핑하지 않고 필요하면 그대로 쓰거나 고쳐서 쓸 수 있게 한다.
    _nameController = TextEditingController();
    _nicknameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _majorController = TextEditingController();
    _studentIdController = TextEditingController();
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
        // AuthController.markProfileCompleted가 전역 상태를 AuthAuthenticated로
        // 바꾸는 즉시 app.dart가 HomePage로 전환하므로, 이 위젯에서 별도로
        // setState(_isSubmitting = false)를 호출할 필요가 없다(이미 화면이 사라진다).
        ref.read(authControllerProvider.notifier).markProfileCompleted(user);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 회원가입을 완료해야 메인 화면으로 넘어갈 수 있으므로, 뒤로가기는
        // '취소하고 로그아웃'으로 취급해 로그인 화면으로 돌려보낸다.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
        title: const Text(
          '회원 정보 입력',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignUpTextField(
                label: '이름',
                hintText: '이름을 입력해주세요',
                icon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
              ),
              SignUpTextField(
                label: '닉네임',
                hintText: '닉네임을 입력해주세요',
                icon: Icons.explore_outlined,
                controller: _nicknameController,
                errorText: _nicknameError,
              ),
              SignUpTextField(
                label: '이메일',
                hintText: '이메일을 입력해주세요',
                icon: Icons.mail_outline,
                controller: _emailController,
                enabled: false,
              ),
              SignUpTextField(
                label: '전공',
                hintText: '전공을 입력해주세요',
                icon: Icons.school_outlined,
                controller: _majorController,
                errorText: _majorError,
              ),
              SignUpTextField(
                label: '학번',
                hintText: '학번을 입력해주세요',
                icon: Icons.menu_book_outlined,
                controller: _studentIdController,
                // Figma(node-id 3018:258)에는 형식 검증 문구가 따로 없지만, 학번은
                // 숫자로만 구성되므로 키보드 단계에서부터 숫자만 입력되게 막고,
                // 제출 시에도 한 번 더 검증한다(붙여넣기 등으로 우회하는 경우 대비).
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _studentIdError,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF31C1FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          '작성 완료',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
