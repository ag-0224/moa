import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MOA 전역에서 재사용하는 입력창(라벨 + 둥근 테두리 입력창 + 아래쪽 에러 메시지).
/// 원래 회원가입 화면(presentation/pages/sign_up/widgets/)에만 있던 위젯을,
/// 다른 화면에서도 같은 모양의 입력창이 필요할 때 재사용할 수 있도록 공통
/// 위젯 폴더로 옮겼다.
///
/// TechTalk의 UnderValidateTextField(presentation/widgets/common/input/)와 같은
/// 위치·역할이지만, 그 위젯은 flutter_hooks와 비동기 검증(FutureOr) 콜백을 쓰는
/// 반면 MOA는 hooks 계열 패키지를 쓰지 않으므로 제출 시점에 동기적으로 계산한
/// 에러 메시지를 errorText로 받는 단순한 형태로 만들었다.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  static const _borderColor = Color(0xFF8B8B8B);
  static const _hintColor = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _hintColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 14, color: _hintColor),
              prefixIcon: Icon(icon, size: 22, color: _hintColor),
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF6F6F9),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: errorText != null ? Colors.red : _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: errorText != null ? Colors.red : _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF31C1FF)),
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(errorText!, style: const TextStyle(fontSize: 14, color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
