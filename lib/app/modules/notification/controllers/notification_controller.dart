import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/app/data/models/notification_model.dart';
import 'package:lifesync_app/app/data/providers/notification_provider.dart';
import 'package:lifesync_app/app/data/providers/wallet_provider.dart';
import 'package:lifesync_app/app/data/providers/transaction_provider.dart';
import 'package:lifesync_app/app/data/providers/task_provider.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/core/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationProvider _notificationProvider = NotificationProvider();
  final WalletProvider _walletProvider = WalletProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final TaskProvider _taskProvider = TaskProvider();
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    print("[NotificationController] onInit called");
    super.onInit();
    loadNotificationsFlow();
  }

  Future<void> loadNotificationsFlow() async {
    try {
      isLoading.value = true;
      // 1. Fetch existing notifications from Supabase
      await fetchNotificationsOnly();

      // 2. Generate new system notifications for today/yesterday if missing
      await generateSystemNotifications();

      // 3. Re-fetch final notifications
      await fetchNotificationsOnly();

      // 4. Mark all as read since user has viewed the inbox
      await markAllAsReadSilent();
    } catch (e) {
      print("[NotificationController] ERROR in loadNotificationsFlow: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotificationsOnly() async {
    final fetched = await _notificationProvider.fetchNotifications();
    notifications.assignAll(fetched);
    print("[NotificationController] Loaded ${notifications.length} notifications.");
  }

  Future<void> markAllAsReadSilent() async {
    try {
      await _notificationProvider.markAllAsRead();
      // Mark read locally to prevent unnecessary reload
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].isUnread) {
          notifications[i] = notifications[i].copyWith(isUnread: false);
        }
      }
      notifications.refresh();
    } catch (e) {
      print("[NotificationController] ERROR in markAllAsReadSilent: $e");
    }
  }

  String _formatCurrency(double amount) {
    final String val = amount.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return val.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  bool _isSameDay(DateTime? d1, DateTime d2) {
    if (d1 == null) return false;
    final localD1 = d1.toLocal();
    return localD1.year == d2.year &&
        localD1.month == d2.month &&
        localD1.day == d2.day;
  }

  Future<void> generateSystemNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      print("[NotificationController] Skip notification generation: User is null");
      return;
    }

    print("[NotificationController] Generating dynamic system notifications...");
    try {
      // Fetch data for metrics computation
      final walletsList = await _walletProvider.fetchWallets();
      final txsList = await _transactionProvider.fetchTransactions();
      final tasksList = await _taskProvider.fetchTasks();

      final now = DateTime.now();
      
      // Loop over Today and Yesterday
      final daysToCheck = [
        now, // Today
        now.subtract(const Duration(days: 1)), // Yesterday
      ];

      for (var targetDate in daysToCheck) {
        // 1. Yesterday's Report (6:00 AM)
        // This is reports about the day prior to targetDate.
        final sixAM = DateTime(targetDate.year, targetDate.month, targetDate.day, 6, 0);
        if (now.isAfter(sixAM)) {
          final reportDate = targetDate.subtract(const Duration(days: 1));
          final dateKey = "yesterday_report_${reportDate.year}_${reportDate.month}_${reportDate.day}";

          if (!notifications.any((n) => n.type == dateKey)) {
            final dateTasks = tasksList.where((t) => _isSameDay(t.dueDate, reportDate)).toList();
            final completedTasks = dateTasks.where((t) => t.isCompleted).length;
            final totalTasks = dateTasks.length;

            final dateTxs = txsList.where((t) => _isSameDay(t.transactionDate, reportDate)).toList();
            final income = dateTxs.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
            final expense = dateTxs.where((t) => t.type == 'outcome').fold(0.0, (sum, t) => sum + t.amount);

            String body = "Kemarin Anda menyelesaikan $completedTasks dari $totalTasks tugas.";
            body += " Pemasukan: Rp ${_formatCurrency(income)}, Pengeluaran: Rp ${_formatCurrency(expense)}.";

            print("[NotificationController] Creating 6 AM report for ${reportDate.toIso8601String()}");
            await _notificationProvider.createNotification(NotificationModel(
              title: "Laporan Kemarin",
              body: body,
              type: dateKey,
              icon: "insights_outlined",
              createdAt: sixAM,
            ));

            // Also schedule local notification if targetDate is today
            if (targetDate.day == now.day) {
              final todayTasks = tasksList.where((t) => _isSameDay(t.dueDate, now)).length;
              await NotificationService().scheduleDaily6AM(
                completedTasksYesterday: completedTasks,
                expensesYesterday: expense,
                tasksToday: todayTasks,
              );
            }
          }
        }

        // 2. Schedule Reminder (12:00 PM)
        final twelvePM = DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0);
        if (now.isAfter(twelvePM)) {
          final dateKey = "schedule_reminder_${targetDate.year}_${targetDate.month}_${targetDate.day}";

          if (!notifications.any((n) => n.type == dateKey)) {
            final dateTasks = tasksList.where((t) => _isSameDay(t.dueDate, targetDate)).toList();
            final totalTasks = dateTasks.length;

            String body = totalTasks > 0
                ? "Hari ini Anda memiliki $totalTasks tugas terjadwal. Tetap semangat!"
                : "Anda belum menjadwalkan tugas untuk hari ini. Mari rencanakan hari Anda sekarang!";

            print("[NotificationController] Creating 12 PM reminder for ${targetDate.toIso8601String()}");
            await _notificationProvider.createNotification(NotificationModel(
              title: "Pengingat Jadwal",
              body: body,
              type: dateKey,
              icon: "assignment_outlined",
              createdAt: twelvePM,
            ));

            if (targetDate.day == now.day) {
              await NotificationService().scheduleDaily12PM(isTodayEmpty: totalTasks == 0);
            }
          }
        }

        // 3. Analysis Reminder (6:00 PM)
        final sixPM = DateTime(targetDate.year, targetDate.month, targetDate.day, 18, 0);
        if (now.isAfter(sixPM)) {
          final dateKey = "analysis_reminder_${targetDate.year}_${targetDate.month}_${targetDate.day}";
          if (!notifications.any((n) => n.type == dateKey)) {
            final totalBalance = walletsList.fold(0.0, (sum, w) => sum + (w.balance ?? 0.0));
            final body = "Waktunya menganalisis produktivitas & keuangan. Saldo total dompet aktif Anda saat ini adalah Rp ${_formatCurrency(totalBalance)}.";

            print("[NotificationController] Creating 6 PM analysis reminder for ${targetDate.toIso8601String()}");
            await _notificationProvider.createNotification(NotificationModel(
              title: "Pengingat Analisis",
              body: body,
              type: dateKey,
              icon: "insights_outlined",
              createdAt: sixPM,
            ));

            if (targetDate.day == now.day) {
              await NotificationService().scheduleDaily6PM(totalBalance: totalBalance);
            }
          }
        }

        // 4. Midnight Summary (12:00 AM / 23:59 PM)
        final midnight = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);
        if (now.isAfter(midnight)) {
          final dateKey = "midnight_summary_${targetDate.year}_${targetDate.month}_${targetDate.day}";

          if (!notifications.any((n) => n.type == dateKey)) {
            final dateTasks = tasksList.where((t) => _isSameDay(t.dueDate, targetDate)).toList();
            final completedTasks = dateTasks.where((t) => t.isCompleted).length;
            final totalTasks = dateTasks.length;

            final dateTxs = txsList.where((t) => _isSameDay(t.transactionDate, targetDate)).toList();
            final expense = dateTxs.where((t) => t.type == 'outcome').fold(0.0, (sum, t) => sum + t.amount);

            final body = "Hari ini selesai! Anda telah menyelesaikan $completedTasks dari $totalTasks tugas dan mencatat pengeluaran sebesar Rp ${_formatCurrency(expense)}.";

            print("[NotificationController] Creating midnight summary for ${targetDate.toIso8601String()}");
            await _notificationProvider.createNotification(NotificationModel(
              title: "Kesimpulan Harian",
              body: body,
              type: dateKey,
              icon: "check_circle_outline",
              createdAt: midnight,
            ));

            if (targetDate.day == now.day) {
              await NotificationService().scheduleDaily12AM(
                expensesToday: expense,
                completedTasksToday: completedTasks,
                totalTasksToday: totalTasks,
              );
            }
          }
        }
      }
    } catch (e) {
      print("[NotificationController] ERROR in generateSystemNotifications: $e");
    }
  }
}
