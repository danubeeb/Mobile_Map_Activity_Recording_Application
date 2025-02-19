
import 'dart:io';
import 'package:application_map_todolist/storage/storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class EventNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    await _requestNotificationPermission();
    await _requestScheduleExactAlarmPermission();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
      },
    );
  }

  Future<void> scheduleNotification(int id, String title, String description, DateTime from, DateTime to, bool From, bool To) async {
    bool onNotify = await EventStorage().loadSettingNotify();
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    
    if(onNotify) {
      if (From) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'กิจกรรม $title เริ่มต้นแล้ว!',
          'อย่าลืมเข้าร่วมและสนุกไปกับกิจกรรมของคุณ',
          tz.TZDateTime.from(from, tz.local),
          generalNotificationDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      if (To) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id + 1,
          'กิจกรรม $title จบลงแล้ว!',
          'หวังว่าคุณจะได้รับประสบการณ์ที่ดีจากกิจกรรมนี้',
          tz.TZDateTime.from(to, tz.local),
          generalNotificationDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  initNotifications() {}
}

  Future<void> _requestScheduleExactAlarmPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  final EventNotificationService notificationService = EventNotificationService();



