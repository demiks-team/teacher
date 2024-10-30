class GeneralHelpers {
  static String formatNumber(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    } else {
      double truncatedValue = (value * 100).floor() / 100.0;
      return truncatedValue.toStringAsFixed(2);
    }
  }
}
