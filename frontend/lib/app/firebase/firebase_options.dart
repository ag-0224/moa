import 'package:firebase_core/firebase_core.dart';
import '../environment/flavor.dart';

/// 현재 활성화된 Flavor(DEV / PROD)의 FirebaseOptions를 반환합니다.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform => Flavor.env.firebaseOptions;
}
