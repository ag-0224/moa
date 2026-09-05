import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../app/environment/flavor.dart';

/// Firebase Authentication으로 구글/애플 로그인을 수행한다.
/// TechTalk 프로젝트(lib/features/auth)의 구현 패턴을 그대로 따른다.
abstract interface class FirebaseAuthDataSource {
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<void> signOut();
}

final class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl([FirebaseAuth? firebaseAuth])
      : _customFirebaseAuth = firebaseAuth;

  final FirebaseAuth? _customFirebaseAuth;

  FirebaseAuth get _firebaseAuth {
    if (_customFirebaseAuth != null) return _customFirebaseAuth;
    try {
      return FirebaseAuth.instanceFor(app: Flavor.firebaseApp);
    } catch (error) {
      throw Exception(
        'Firebase가 아직 초기화되지 않았거나 설정이 누락되었습니다. '
        'Google/Apple 로그인을 사용하려면 Firebase 설정(google-services.json / GoogleService-Info.plist)을 완료하세요: $error',
      );
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return _guard('구글 로그인', () async {
      final env = Flavor.env;
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb || defaultTargetPlatform == TargetPlatform.iOS
            ? env.googleIosClientId
            : null,
        serverClientId: env.googleServerClientId,
        scopes: const ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('구글 로그인이 취소되었습니다.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _firebaseAuth.signInWithCredential(credential);
    });
  }

  @override
  Future<UserCredential> signInWithApple() {
    return _guard('애플 로그인', () async {
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      return _firebaseAuth.signInWithCredential(oauthCredential);
    });
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  /// [action]을 실행하고, 이미 의미 있는 [Exception]이면 그대로, 아니라면
  /// "[label] 오류: ..." 형태로 감싸 다시 던진다. signInWithGoogle/signInWithApple의
  /// 공통 에러 래핑 로직을 모은다.
  Future<T> _guard<T>(String label, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('$label 오류: $error');
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
