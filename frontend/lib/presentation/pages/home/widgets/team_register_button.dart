import 'package:flutter/material.dart';

/// "팀 등록하기" 플로팅 버튼. 처음에는 아이콘+글자가 있는 알약(pill) 모양이다가,
/// 스크롤을 내리면 원형 아이콘 버튼으로 자연스럽게 줄어든다.
///
/// Figma(node-id 3073-49)의 플로팅 버튼 프레임(3094:1364) 바로 옆에, 같은
/// y좌표에 딱 버튼 오른쪽 끝과 맞닿은 작은 원(Ellipse 1)이 겹쳐 있었는데, 이건
/// "스크롤하면 이 알약이 이 원으로 줄어든다"는 모핑 타깃을 나타낸 것으로 해석해
/// AnimatedContainer로 너비를 보간하는 방식으로 구현했다.
///
/// 스크롤 위치를 직접 듣는 로직을 위젯 내부에 캡슐화해서, 이 버튼을 쓰는 쪽
/// (home_page.dart)은 ScrollController만 넘겨주면 되도록 했다.
class TeamRegisterButton extends StatefulWidget {
  const TeamRegisterButton({super.key, required this.scrollController, required this.onPressed});

  final ScrollController scrollController;
  final VoidCallback onPressed;

  @override
  State<TeamRegisterButton> createState() => _TeamRegisterButtonState();
}

class _TeamRegisterButtonState extends State<TeamRegisterButton> {
  static const double _collapseScrollOffset = 40;
  static const double _circleSize = 60;
  static const double _expandedWidth = 132;
  static const double _textWrapperWidth = _expandedWidth - _circleSize;
  static const Duration _duration = Duration(milliseconds: 200);
  static const Color _brandColor = Color(0xFF31C1FF);

  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.scrollController.hasClients) return;
    final collapsed = widget.scrollController.offset > _collapseScrollOffset;
    if (collapsed != _collapsed) {
      setState(() => _collapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeInOut,
      width: _collapsed ? _circleSize : _expandedWidth,
      height: _circleSize,
      child: Material(
        color: _brandColor,
        elevation: 4,
        shape: _collapsed
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(_circleSize / 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white),
              // 너비를 0까지 줄이고 ClipRect로 감싸서, 컨테이너가 줄어드는 동안
              // 텍스트가 밖으로 넘쳐 보이지(overflow) 않도록 한다.
              AnimatedContainer(
                duration: _duration,
                curve: Curves.easeInOut,
                width: _collapsed ? 0 : _textWrapperWidth,
                child: ClipRect(
                  child: AnimatedOpacity(
                    duration: _duration,
                    opacity: _collapsed ? 0 : 1,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        '팀 등록하기',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
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
