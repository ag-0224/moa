import 'package:flutter_test/flutter_test.dart';
import 'package:moa/app/environment/environment.enum.dart';
import 'package:moa/app/environment/env.dart';
import 'package:moa/app/environment/flavor.dart';

void main() {
  group('Flavor & Environment Test', () {
    test('DEV Flavor 초기화 테스트', () async {
      Flavor.initialize(Environment.dev);
      await Flavor.setup();

      expect(Flavor.env, Environment.dev);
      expect(Env.isDev, isTrue);
      expect(Env.isProd, isFalse);
      expect(Env.currentEnvironment.type, 'DEV');
      expect(Flavor.env.apiBaseUrl, 'http://localhost:8080/api/v1');
    });

    test('PROD Flavor 초기화 테스트', () async {
      Flavor.initialize(Environment.prod);
      await Flavor.setup();

      expect(Flavor.env, Environment.prod);
      expect(Env.isDev, isFalse);
      expect(Env.isProd, isTrue);
      expect(Env.currentEnvironment.type, 'PROD');
      expect(Flavor.env.apiBaseUrl, 'https://api.moa.app/api/v1');
    });
  });
}
