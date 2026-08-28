import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// POST /auth/login으로 발급받은 MOA 액세스 토큰을 기기에 보관한다.
abstract interface class TokenStorage {
  Future<void> save(String accessToken);
  Future<String?> read();
  Future<void> clear();
}

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'moa_access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(String accessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    } catch (_) {}
  }

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (_) {}
  }
}
