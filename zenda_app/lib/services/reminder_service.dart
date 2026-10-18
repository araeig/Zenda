import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../l10n/app_localizations.dart';
import 'event_service.dart';
import 'locale_service.dart';
import 'task_service.dart';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _syncing = false;
  static bool _syncAgain = false;

  static const String enabledKey = 'notificationsEnabled';
  static const int _horizonDays = 14;
  static const int _maxScheduled = 60;
  static const Duration _leadTime = Duration(minutes: 15);
  static const int _allDayHour = 9;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static AndroidNotificationDetails _androidDetails(AppLocalizations t) =>
      AndroidNotificationDetails(
        'zenda_reminders',
        t.remindersChannel,
        channelDescription: t.remindersChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        color: const Color(0xFF7B337E),
      );

  static Future<void> _init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    if (!supported) return false;
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  static Future<void> cancelAll() async {
    if (!supported) return;
    await _init();
    await _plugin.cancelAll();
  }

  static Future<void> sync() async {
    if (!supported) return;
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _syncAgain = false;
        await _syncOnce();
      } while (_syncAgain);
    } catch (e) {
      print('Reminder sync error: $e');
    } finally {
      _syncing = false;
    }
  }

  static DateTime? _parseDay(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static Duration? _parseTime(dynamic value) {
    if (value == null) return null;
    final parts = value.toString().split(':');
    if (parts.length < 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return Duration(hours: hours, minutes: minutes);
  }

  static String _clock(Duration time) =>
      '${time.inHours.toString().padLeft(2, '0')}:${(time.inMinutes % 60).toString().padLeft(2, '0')}';

  static Future<void> _syncOnce() async {
    await _init();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(enabledKey) ?? true;
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!enabled || !loggedIn) {
      await _plugin.cancelAll();
      return;
    }

    final t = lookupAppLocalizations(currentLocale.value);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final until = today.add(const Duration(days: _horizonDays));

    final projects = await TaskService().getAll();
    final events = await EventService().getRange(today, until);
    if (projects == null || events == null) return;

    final reminders = <_Reminder>[];

    for (final e in events) {
      final day = _parseDay(e['date']);
      if (day == null) continue;
      final start = _parseTime(e['startTime']);
      final address = (e['address'] ?? '').toString().trim();
      final place = address.isEmpty ? '' : ' · $address';
      reminders.add(
        _Reminder(
          id: (e['id'] as int) * 2 + 1,
          at: start != null
              ? day.add(start).subtract(_leadTime)
              : day.add(const Duration(hours: _allDayHour)),
          title: e['title'] ?? t.eventWord,
          body:
              (start != null
                  ? t.reminderEventAt(_clock(start))
                  : t.reminderEventAllDay) +
              place,
        ),
      );
    }

    for (final p in projects) {
      final List<dynamic> tasks = p['tasks'] ?? [];
      for (final task in tasks) {
        if (task['done'] == true) continue;
        final day = _parseDay(task['dueDate']);
        if (day == null || day.isBefore(today) || day.isAfter(until)) continue;
        final time = _parseTime(task['dueTime']);
        final project = ' · ${p['name'] ?? ''}';
        reminders.add(
          _Reminder(
            id: (task['id'] as int) * 2,
            at: time != null
                ? day.add(time).subtract(_leadTime)
                : day.add(const Duration(hours: _allDayHour)),
            title: task['title'] ?? t.calendarTask,
            body:
                (time != null
                    ? t.reminderTaskAt(_clock(time))
                    : t.reminderTaskToday) +
                project,
          ),
        );
      }
    }

    reminders.removeWhere((r) => !r.at.isAfter(now));
    reminders.sort((a, b) => a.at.compareTo(b.at));

    final details = NotificationDetails(android: _androidDetails(t));
    await _plugin.cancelAll();
    for (final r in reminders.take(_maxScheduled)) {
      await _plugin.zonedSchedule(
        r.id,
        r.title,
        r.body,
        tz.TZDateTime.from(r.at, tz.UTC),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

class _Reminder {
  final int id;
  final DateTime at;
  final String title;
  final String body;

  _Reminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });
}
