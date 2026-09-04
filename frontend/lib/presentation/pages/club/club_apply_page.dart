import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/di_providers.dart';
import '../../widgets/common/button/app_rounded_button.dart';

/// 동아리 상세 화면의 "지원 하기"를 누르면 이동하는 자기소개 작성 화면.
/// 제출에 성공하면 true를 pop해서 상세 화면(ClubDetailPage)이 최신 신청
/// 상태(PENDING)를 다시 불러오게 한다.
class ClubApplyPage extends ConsumerStatefulWidget {
  const ClubApplyPage({super.key, required this.clubId, required this.clubName});

  final int clubId;
  final String clubName;

  @override
  ConsumerState<ClubApplyPage> createState() => _ClubApplyPageState();
}

class _ClubApplyPageState extends ConsumerState<ClubApplyPage> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  // backend ApplyClubRequest.selfIntroduction의 @Size(min = 20)과 맞춘 값.
  static const int _minLength = 20;
  static const Color _blue = Color(0xFF31C1FF);
  static const Color _borderColor = Color(0xFF8B8B8B);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // AppRoundedButton은 isLoading일 때 onPressed를 비활성화하지만, 그건
    // "다음 프레임"부터 반영된다 — setState(_isSubmitting = true)는 필드값을
    // 즉시 바꿔도 실제 리빌드는 다음 프레임에야 일어나므로, 아주 빠르게 두 번
    // 탭하면(같은 프레임 안에서) onPressed가 아직 비활성화되기 전이라 _submit이
    // 중복 호출될 수 있다. 그 경쟁 상태에서 먼저 끝난 호출이 navigator.pop으로
    // 이 화면을 이미 벗어난 뒤, 나중에 끝난 두 번째 호출이 그 시점에 deactivate된
    // (그러나 아직 mounted는 true인) 이 위젯의 ref/context를 건드리면서
    // "Looking up a deactivated widget's ancestor is unsafe" 에러가 날 수 있다 —
    // 그래서 진입 시점에 이미 제출 중이면 곧바로 걸러낸다.
    if (_isSubmitting) return;

    final text = _controller.text.trim();
    if (text.length < _minLength) {
      setState(() => _errorText = '자기소개를 $_minLength자 이상 입력해주세요. (현재 ${text.length}자)');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    // await 이후에 ScaffoldMessenger.of(context)/Navigator.of(context)를 호출하면,
    // 그 사이에 사용자가 뒤로가기 등으로 화면을 벗어나 위젯이 deactivate된 경우
    // "Looking up a deactivated widget's ancestor is unsafe" 에러가 난다.
    // mounted 체크만으로는 막을 수 없으므로(디액티베이트된 상태에서도 mounted는
    // true다), await 전에 미리 참조를 캡처해두고 그 참조만 사용한다. 그 참조
    // 자신(ScaffoldMessengerState/NavigatorState)도 각자 State라 .mounted를
    // 따로 갖고 있어서, 실제로 쓰기 전에 한 번 더 확인한다.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ref.read(applyToClubUseCaseProvider)(widget.clubId, text);
      if (!mounted) return;
      if (messenger.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('지원서를 제출했어요. 승인을 기다려주세요.')));
      }
      if (navigator.mounted) {
        navigator.pop(true);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      // 이 화면(또는 비슷한 async-gap 버그)이 나중에 또 재발하면, 여기 콘솔
      // 로그의 stackTrace가 정확히 어느 줄에서 터졌는지 알려준다 — 사용자에게
      // 보여주는 $e 문자열만으로는(예: 프레임워크 에러 메시지) 원인 위치를
      // 알 수 없다.
      debugPrint('ClubApplyPage._submit 실패: $e\n$stackTrace');
      setState(() {
        _isSubmitting = false;
        _errorText = '지원서 제출에 실패했어요: $e';
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
        title: Text(
          widget.clubName,
          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                '자기소개',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _borderColor),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '동아리 회장에게만 공개돼요. 최소 $_minLength자 이상 입력해주세요.',
                    hintStyle: const TextStyle(fontSize: 14, color: _borderColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _errorText != null ? Colors.red : _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _errorText != null ? Colors.red : _borderColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: _blue),
                    ),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!, style: const TextStyle(fontSize: 14, color: Colors.red)),
              ],
              const SizedBox(height: 20),
              AppRoundedButton(
                onPressed: _submit,
                isLoading: _isSubmitting,
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                child: const Text(
                  '지원서 제출',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.4),
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
