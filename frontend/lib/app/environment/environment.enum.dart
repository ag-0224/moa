import 'package:firebase_core/firebase_core.dart';

import 'firebase/firebase_options_dev.dart' as dev_firebase;
import 'firebase/firebase_options_prod.dart' as prod_firebase;

enum Environment {
  dev(
    type: 'DEV',
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
    isDebugMode: true,
    googleServerClientId:
        '535931109546-meu15i24ennva86ke736ls45ecpdgtl4.apps.googleusercontent.com',
    googleIosClientId:
        '535931109546-sakkm84ocovltm89r59a3slt8emghj7c.apps.googleusercontent.com',
  ),
  prod(
    type: 'PROD',
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://15.164.215.175:8080/api/v1',
    ),
    isDebugMode: false,
    googleServerClientId:
        '271473387630-vbi8s1jak0f8bk2bf04viuaqva13gpf7.apps.googleusercontent.com',
    googleIosClientId:
        '271473387630-12fad6jcpps98nk6de4gc098m1vie977.apps.googleusercontent.com',
  );

  final String type;
  final String apiBaseUrl;
  final String dotFileName;
  final bool isDebugMode;
  final String googleServerClientId;
  final String googleIosClientId;

  const Environment({
    required this.type,
    required this.apiBaseUrl,
    required this.isDebugMode,
    required this.googleServerClientId,
    required this.googleIosClientId,
  }) : dotFileName = type == 'DEV' ? '.env.dev' : '.env.prod';

  FirebaseOptions get firebaseOptions => switch (this) {
        dev => dev_firebase.DefaultFirebaseOptions.currentPlatform,
        prod => prod_firebase.DefaultFirebaseOptions.currentPlatform,
      };
}
