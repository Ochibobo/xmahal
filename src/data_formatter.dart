import 'package:meta/meta.dart';

//A class to perform type conversions
class Val {
  //Try to convert a value to an integer
  static int asInt({@required var value}) {
    int intValue;
    try {
      intValue = int.parse(value);
    } catch (e, s) {
      print('Exception:\n $e');
      print('Stack trace:\n $s');
    }
    return intValue;
  }

  //Try to convert a value to a double
  static double asDouble({@required var value}) {
    double doubleValue;
    try {
      doubleValue = double.parse(value);
    } catch (e, s) {
      print('Exception:\n $e');
      print('Stack trace:\n $s');
    }
    return doubleValue;
  }

  //Try to convert a value to DateTime
  static DateTime asDateTime({@required var value}) {
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(value);
    } catch (e, s) {
      print('Exception:\n $e');
      print('Stack trace:\n $s');
    }

    return dateTime;
  }
}
