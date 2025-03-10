import 'package:intl/intl.dart';

class Utils {

static String toDateTime(DateTime date) {
  final thaiLocale = 'th';
  final dateFormatDate = DateFormat('EEE dd MMM yyyy', thaiLocale);
  final dateFormatTime = DateFormat('เวลา: HH:mm', thaiLocale);
  return '${dateFormatDate.format(date)}\n${dateFormatTime.format(date)}';
}


  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd('th').format(dateTime) ;

    return '$date' ; 

  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime) ;

    return '$time' ; 

  }

  static bool isWeekend(DateTime dateTime) {
    return dateTime.weekday == DateTime.saturday || dateTime.weekday == DateTime.sunday;
  }


  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }


  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  


}