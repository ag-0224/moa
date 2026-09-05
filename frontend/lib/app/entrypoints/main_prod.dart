import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../environment/environment.enum.dart';
import '../environment/flavor.dart';
import '../../presentation/app.dart';

Future<void> main() async {
  Flavor.initialize(Environment.prod);
  await Flavor.setup();

  runApp(const ProviderScope(child: MoaApp()));
}
