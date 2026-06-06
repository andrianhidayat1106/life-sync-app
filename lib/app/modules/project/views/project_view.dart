import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/core/widgets/header.dart';
import '../../../../core/constants/app_colors.dart';

import '../controllers/project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Header(
                          title: controller.getUserFullName(),
                          profileImagePath: controller.getUserAvatarUrl(),
                        )),
                    const SizedBox(height: 24),
                    const Text(
                      'Proyek Berjalan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau kemajuan dan kelola sumber daya proyek Anda dengan efisien.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Dynamic Projects List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF065F46),
                        ),
                      ),
                    ),
                  );
                }

                final list = controller.projects;
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'Tidak ada proyek untuk ditampilkan',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: list.map((project) {
                      final projectId = project.id?.toString() ?? '';
                      final progress = controller.getProgressPercentage(
                        projectId,
                      );
                      final progressLabel =
                          "${(progress * 100).toStringAsFixed(0)}%";

                      final remaining = controller.getRemainingTasks(projectId);
                      final total = controller.getTotalTasks(projectId);
                      final tasksLabel =
                          "$remaining Tugas Tersisa (Total: $total)";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            print(
                              "[ProjectView] Clicked project card: ID = ${project.id}, Name = ${project.name}",
                            );
                            controller.prepareEditForm(project);
                            Get.toNamed('/project/create');
                          },
                          child: _buildProjectCard(
                            project.name,
                            project.description ?? 'Tidak ada deskripsi',
                            progress,
                            progressLabel,
                            tasksLabel,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // External Project Card

              // Bottom Spacing for Navigation
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(
            "[ProjectView] Floating Action Button clicked - navigating to /project/create",
          );
          controller.prepareCreateForm();
          Get.toNamed('/project/create');
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }



  Widget _buildProjectCard(
    String title,
    String description,
    double progress,
    String progressLabel,
    String tasks,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kemajuan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                progressLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFEFF4FF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF065F46),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                tasks,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
