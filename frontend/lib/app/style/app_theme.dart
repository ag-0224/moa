import 'package:flutter/material.dart';

import 'app_color.dart';

abstract class AppTheme {
  static ThemeData get light {
    final appColor = AppColor();
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: appColor.brand3,
      scaffoldBackgroundColor: appColor.white,
      extensions: [
        appColor,
      ],
    );
  }

  static ThemeData get dark {
    final appColor = AppColor.dark();
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: appColor.brand3,
      scaffoldBackgroundColor: appColor.black,
      extensions: [
        appColor,
      ],
    );
  }
}
