import 'package:intl/intl.dart';

String formatNumber(dynamic number) {
  var f = NumberFormat("#,##0.00", "en_US");
  
  if (number == null) {
    return "0.00";
  } else if (number is int || number is double) {
    return f.format(number);
  } else if (number is String) {
    try {
      var parsedNumber = double.parse(number);
      return f.format(parsedNumber);
    } catch (e) {
      return "0.00"; // Return default format for invalid strings
    }
  } else {
    return "0.00"; // Default format for unsupported types
  }
}