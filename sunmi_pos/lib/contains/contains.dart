import 'package:intl/intl.dart';

formatNumber(dynamic myNumber) {
  // Convert number into a string if it was not a string previously
  String stringNumber = myNumber.toString();

  // Convert number into double to be formatted.
  // Default to zero if unable to do so
  double doubleNumber = double.parse(stringNumber) ?? 0;

  // Set number format to use
  NumberFormat numberFormat =
      new NumberFormat.currency(locale: "vi_VN", symbol: "");

  return numberFormat.format(doubleNumber);
}
