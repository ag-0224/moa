import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      return FirebaseAuth.instance;
    } catch (error) {
      throw Exception(
        'Firebase가 아직 초기화되지 않았거나 설정이 누락되었습니다. '
        'Google/Apple 로그인을 사용하려면 Firebase 설정(google-services.json / GoogleService-Info.plist)을 완료하세요: $error',
      );
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('구글 로그인이 취소되었습니다.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithApple() async {
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
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
