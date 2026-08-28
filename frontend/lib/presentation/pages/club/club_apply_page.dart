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
    final text = _controller.text.trim();
    if (text.length < _minLength) {
      setState(() => _errorText = '자기소개를 $_minLength자 이상 입력해주세요. (현재 ${text.length}자)');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref.read(applyToClubUseCaseProvider)(widget.clubId, text);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('지원서를 제출했어요. 승인을 기다려주세요.')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
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
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text('${widget.clubName} 지원하기'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: const Text('지원서 제출', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
