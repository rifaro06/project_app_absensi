import '../../../core/utils/date_helper.dart';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/attendance_model.dart';

class AttendanceStatusCard extends StatelessWidget {
  final AttendanceModel? todayAttendance;
  final bool isLoading;

  const AttendanceStatusCard({
    super.key,
    required this.todayAttendance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final hasData = todayAttendance != null;
    final isIzin = hasData && todayAttendance!.isIzin;
    final isCheckedIn = hasData && todayAttendance!.isCheckedIn;
    final isCheckedOut = hasData && todayAttendance!.isCheckedOut;

    // Menentukan Status Tag
    String statusTitle = 'Belum Absen Hari Ini';
    Color statusColor = AppColors.accentWarning;
    IconData statusIcon = Icons.hourglass_empty_rounded;

    if (isIzin) {
      statusTitle = 'Izin Tercatat';
      statusColor = AppColors.accentWarning;
      statusIcon = Icons.event_note_rounded;
    } else if (isCheckedOut) {
      statusTitle = 'Absen Selesai (Pulang)';
      statusColor = AppColors.primary;
      statusIcon = Icons.check_circle_rounded;
    } else if (isCheckedIn) {
      statusTitle = 'Sudah Absen Masuk';
      statusColor = AppColors.primary;
      statusIcon = Icons.login_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Kehadiran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Detail Masuk & Pulang
          if (isIzin) ...[
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keterangan: ${todayAttendance?.alasanIzin ?? "Izin"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                // Absen Masuk
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.login,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Absen Masuk',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateHelper.formatTime(todayAttendance?.checkIn),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Absen Pulang
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentCoral.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: AppColors.accentCoral,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Absen Keluar',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateHelper.formatTime(todayAttendance?.checkOut),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          if (todayAttendance?.checkInAddress != null &&
              todayAttendance!.checkInAddress!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    todayAttendance!.checkInAddress!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
