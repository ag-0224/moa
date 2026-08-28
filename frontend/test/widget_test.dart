import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// `flutter create`가 생성한 기본 카운터 템플릿 테스트(MyApp 참조)를 이 프로젝트에
// 맞게 교체했다. MoaApp을 직접 pump하는 테스트는 Firebase 초기화, 실제 네트워크
// 호출(Dio), flutter_secure_storage 플랫폼 채널에 의존하는
// AuthController._restoreSession을 함께 트리거하므로, 이를 목(mock)으로 대체할
// 테스트 인프라(Provider override 등)가 준비되기 전까지는 최소한의 스모크
// 테스트만 둔다.
void main() {
  testWidgets('MaterialApp이 정상적으로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('MOA')),
      ),
    );

    expect(find.text('MOA'), findsOneWidget);
  });
}
