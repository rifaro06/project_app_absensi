import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../models/attendance_model.dart';
import '../attendance_detail_page.dart';

class HistoryCard extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback? onDelete;

  const HistoryCard({super.key, required this.attendance, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIzin = attendance.isIzin;

    Color badgeColor = AppColors.primary;
    String badgeText = 'Hadir';

    if (isIzin) {
      badgeColor = AppColors.accentWarning;
      badgeText = 'Izin';
    } else if (attendance.isCheckedOut) {
      badgeColor = AppColors.primary;
      badgeText = 'Selesai';
    } else if (attendance.isCheckedIn) {
      badgeColor = AppColors.primary;
      badgeText = 'Masuk';
    }

    void openDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceDetailPage(attendance: attendance),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: openDetail,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Tanggal & Badge Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateHelper.formatIndonesianDate(
                          attendance.checkIn ?? attendance.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.accentCoral,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Hapus Catatan',
                            onPressed: onDelete,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),

                if (isIzin) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.accentWarning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attendance.alasanIzin != null &&
                                  attendance.alasanIzin!.isNotEmpty
                              ? attendance.alasanIzin!
                              : 'Tidak ada keterangan izin tambahan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Masuk',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateHelper.formatTime(attendance.checkIn),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Pulang',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateHelper.formatTime(attendance.checkOut),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                if (attendance.checkInAddress != null &&
                    attendance.checkInAddress!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          attendance.checkInAddress!,
                          maxLines: 1,
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

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Tombol Lihat Selengkapnya
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lihat Selengkapnya & Peta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
