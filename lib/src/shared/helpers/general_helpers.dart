import 'package:flutter/material.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';

class GeneralHelpers {
  static String formatNumber(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    } else {
      double truncatedValue = (value * 100).floor() / 100.0;
      return truncatedValue.toStringAsFixed(2);
    }
  }

  static Widget getCircularProgressIndicator() {
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 2.0,
      color: HexColor.fromHex(AppColors.accentColor),
    ));
  }
}
