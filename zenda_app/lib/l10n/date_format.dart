import 'package:intl/intl.dart';
import '../services/locale_service.dart';

String get _locale => currentLocale.value.languageCode;

String capitalizeFirst(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

String formatDayMonth(DateTime date) => DateFormat.MMMMd(_locale).format(date);

String formatWeekdayDayMonth(DateTime date) =>
    capitalizeFirst(DateFormat.MMMMEEEEd(_locale).format(date));

String formatShortWeekdayDate(DateTime date) =>
    capitalizeFirst(DateFormat.MMMEd(_locale).format(date));

String formatWeekdayCompact(DateTime date) {
  final format = _locale == 'ar'
      ? DateFormat('EEEEE', _locale)
      : DateFormat.E(_locale);
  return format.format(date).replaceAll('.', '').toUpperCase();
}
