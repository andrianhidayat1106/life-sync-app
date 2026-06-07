import 'package:get/get.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:lifesync_app/app/modules/project/controllers/project_controller.dart';
import 'package:lifesync_app/app/modules/task/controllers/task_controller.dart';
import 'package:lifesync_app/app/data/models/project_model.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final WalletController walletController = Get.find<WalletController>();
  final ProjectController projectController = Get.find<ProjectController>();
  final TaskController taskController = Get.find<TaskController>();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshHomeData();
  }

  Future<void> refreshHomeData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        walletController.refreshData(),
        projectController.loadData(),
        taskController.loadData(),
      ]);
    } catch (e) {
      print("Error refreshing home data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Calculations
  double get totalBalance {
    return walletController.wallets.fold(0.0, (sum, wallet) => sum + (wallet.balance ?? 0.0));
  }

  double get totalIncome {
    return walletController.transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalOutcome {
    return walletController.transactions
        .where((t) => t.type == 'outcome')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Chart data (Heights for 7 bars representing daily transaction volume in the last 7 days)
  List<double> get last7DaysActivity {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<String, double> dayTotals = {};
    
    // Initialize last 7 days keys
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final key = "${date.year}-${date.month}-${date.day}";
      dayTotals[key] = 0.0;
    }
    
    for (var tx in walletController.transactions) {
      final txDate = tx.transactionDate;
      final txLocalDate = DateTime(txDate.year, txDate.month, txDate.day);
      final diff = today.difference(txLocalDate).inDays;
      if (diff >= 0 && diff < 7) {
        final key = "${txLocalDate.year}-${txLocalDate.month}-${txLocalDate.day}";
        dayTotals[key] = (dayTotals[key] ?? 0.0) + tx.amount;
      }
    }
    
    // Convert to list chronologically (oldest to newest)
    final list = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final key = "${date.year}-${date.month}-${date.day}";
      return dayTotals[key] ?? 0.0;
    });
    
    final maxVal = list.fold(0.0, (max, val) => val > max ? val : max);
    if (maxVal == 0) return List.generate(7, (_) => 0.0);
    return list.map((val) => (val / maxVal) * 80.0 + 10.0).toList();
  }

  // Indonesian day labels ('Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab') for the last 7 days chronologically
  List<String> get last7DaysLabels {
    final now = DateTime.now();
    final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return days[date.weekday % 7];
    });
  }

  // Dynamic Lists
  List<ProjectModel> get activeProjects {
    return projectController.projects.take(5).toList();
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    return taskController.tasks.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      // Semua tugas dengan due date hari ini atau sebelumnya (overdue + hari ini)
      // Baik yang sudah selesai maupun belum — agar tidak hilang saat di-ceklis
      return due.compareTo(todayDate) <= 0;
    }).toList();
  }

  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = walletController.transactions.where((t) {
      final txDate = t.transactionDate;
      final txLocalDate = DateTime(txDate.year, txDate.month, txDate.day);
      return txLocalDate.isAtSameMomentAs(today);
    }).toList();
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list;
  }

  List<TransactionModel> get recentTransactions {
    final list = List<TransactionModel>.from(walletController.transactions);
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list.take(5).toList();
  }

  String getUserFullName() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.fullName.value.isNotEmpty) {
        return pc.fullName.value;
      }
    }
    
    // Coba ambil dari auth session jika ada (saat restart aplikasi)
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user.userMetadata != null) {
      final fullName = session.user.userMetadata!['full_name'];
      if (fullName != null && fullName.toString().isNotEmpty) {
        return fullName.toString();
      }
    }
    
    return Get.find<CacheService>().read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.profileImagePath.value.isNotEmpty) {
        return pc.profileImagePath.value;
      }
    }
    return Get.find<CacheService>().read<String>('user_profile_picture') ?? '';
  }
}
