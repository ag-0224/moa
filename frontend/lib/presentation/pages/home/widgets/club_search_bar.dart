import 'package:flutter/material.dart';

/// 검색 모드일 때 HomeAppBar 자리에 대신 보여주는 검색창.
/// 왼쪽 뒤로가기 화살표 + 둥근 테두리 입력창(입력이 있으면 오른쪽에 X
/// 지우기 버튼)으로 구성된다.
class ClubSearchBar extends StatelessWidget {
  const ClubSearchBar({super.key, required this.controller, required this.onBack, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  static const Color _borderColor = Color(0xFF8B8B8B);
  static const Color _hintColor = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: onChanged,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: '원하는 스터디의 이름을 검색해보세요.',
                          hintStyle: TextStyle(fontSize: 14, color: _hintColor),
                        ),
                      ),
                    ),
                    if (controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.clear();
                          onChanged('');
                        },
                        child: const Icon(Icons.close, size: 18, color: _hintColor),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
