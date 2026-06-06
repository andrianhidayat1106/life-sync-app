import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  String _formatCurrency(double amount) {
    final String val = amount.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return val.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Future<void> scheduleDaily6AM({
    required int completedTasksYesterday,
    required double expensesYesterday,
    required int tasksToday,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 6, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String expensesStr = _formatCurrency(expensesYesterday);
    final String message = 'Kemarin selesai $completedTasksYesterday tugas & keluar Rp $expensesStr. Hari ini ada $tasksToday tugas menanti!';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      100,
      'Laporan Kemarin 🌅',
      message,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_6am_channel',
          'Laporan Pagi 06:00',
          channelDescription: 'Laporan kemarin dan jadwal hari ini',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDaily12PM({required bool isTodayEmpty}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    String message = 'Sudah mengisi jadwal tugas untuk hari ini? Mari mulai rencanakan!';
    if (!isTodayEmpty) {
      message = 'Hari ini jadwal tugas Anda sudah terisi. Tetap semangat menyelesaikannya!';
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      200,
      'Pengingat Jadwal ⏰',
      message,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_12pm_channel',
          'Pengingat Siang 12:00',
          channelDescription: 'Pengingat pengisian jadwal tugas',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDaily6PM({required double totalBalance}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String balanceStr = _formatCurrency(totalBalance);
    final String message = 'Saatnya menganalisis keuangan & produktivitas. Total saldo dompet aktif: Rp $balanceStr.';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      250,
      'Pengingat Analisis 📈',
      message,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_6pm_channel',
          'Pengingat Analisis 18:00',
          channelDescription: 'Pengingat untuk menganalisis keuangan dan produktivitas',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDaily12AM({
    required double expensesToday,
    required int completedTasksToday,
    required int totalTasksToday,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 0, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String expensesStr = _formatCurrency(expensesToday);
    final String message = 'Hari ini selesai! Menyelesaikan $completedTasksToday dari $totalTasksToday tugas & total pengeluaran Rp $expensesStr. Selamat malam 😴';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      300,
      'Refleksi Malam Kesimpulan 🌌',
      message,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_12am_channel',
          'Refleksi Malam 24:00',
          channelDescription: 'Rangkuman aktivitas keuangan & tugas harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
