import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. 初始化时区数据库
    tz.initializeTimeZones();
    // 2. 设置本地时区（中国使用 Asia/Shanghai）
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // 2. Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS 初始化设置
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("用户点击了通知，payload: ${response.payload}");
      },
    );

    // 4. 请求 Android 通知权限 (Android 13+)
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  // --- 检查是否有精确闹钟权限 (Android 12+) ---
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        return await androidImplementation.canScheduleExactNotifications() ?? false;
      }
    }
    return true; // iOS 或其他平台默认返回 true
  }

  // --- 请求精确闹钟权限 (引导用户去系统设置) ---
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  // --- 核心方法：设置每日提醒 ---
  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    // 定义通知详情
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'daily_reminder_channel', // id
      '每日记账提醒', // name
      channelDescription: '记得记录今天的开销哦',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // 计算下一次提醒的时间
    final tz.TZDateTime nextTime = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 通知的 ID (固定为0，这样新的设置会覆盖旧的)
      '该记账啦 📒', // 标题
      '今天花了多少钱？快来记一笔吧！', // 内容
      nextTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 精确计时 + 允许休眠时唤醒
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // 🟢 关键：设置为每天匹配时间
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("已设置每日提醒: $nextTime");
  }

  // --- 辅助方法：计算下一次的时间点 ---
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 如果时间已经过了，就设为明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // 取消所有通知
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // --- 发送测试通知（立即显示）---
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'test_channel', // id
      '测试通知', // name
      channelDescription: '用于测试通知功能',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      999, // 测试通知的 ID
      '测试通知 ✅',
      '如果你看到这条通知，说明通知功能正常！',
      platformChannelSpecifics,
    );
    print("测试通知已发送");
  }

  // --- 发送延迟测试通知（1分钟后）---
  Future<void> scheduleTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'test_channel',
      '测试通知',
      channelDescription: '用于测试定时通知功能',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      998,
      '定时测试通知 ⏰',
      '这是1分钟后的定时通知测试',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("定时测试通知已设置，将在 $scheduledTime 触发");
  }
}
