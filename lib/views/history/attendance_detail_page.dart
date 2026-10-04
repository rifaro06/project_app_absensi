import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../models/attendance_model.dart';

class AttendanceDetailPage extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceDetailPage({super.key, required this.attendance});

  LatLng _getCoordinates() {
    if (attendance.checkInLat != null && attendance.checkInLng != null) {
      return LatLng(attendance.checkInLat!, attendance.checkInLng!);
    }

    // Coba parsing dari check_in_location (format "lat, lng")
    if (attendance.checkInLocation != null &&
        attendance.checkInLocation!.contains(',')) {
      final parts = attendance.checkInLocation!.split(',');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    }

    // Default Monas Jakarta jika lokasi kosong
    return const LatLng(-6.1754, 106.8272);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetLatLng = _getCoordinates();

    final isIzin = attendance.isIzin;
    final isCheckedIn = attendance.isCheckedIn;
    final isCheckedOut = attendance.isCheckedOut;

    String statusText = 'Hadir';
    Color statusColor = AppColors.primary;
    IconData statusIcon = Icons.check_circle_rounded;

    if (isIzin) {
      statusText = 'Izin Tercatat';
      statusColor = AppColors.accentWarning;
      statusIcon = Icons.event_note_rounded;
    } else if (isCheckedOut) {
      statusText = 'Presensi Selesai (Pulang)';
      statusColor = AppColors.primary;
      statusIcon = Icons.done_all_rounded;
    } else if (isCheckedIn) {
      statusText = 'Sudah Absen Masuk';
      statusColor = AppColors.primary;
      statusIcon = Icons.login_rounded;
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('detail_location'),
        position: targetLatLng,
        infoWindow: InfoWindow(
          title: statusText,
          snippet: attendance.checkInAddress ?? 'Lokasi Presensi',
        ),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Presensi'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Status & Tanggal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'ID: #${attendance.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    DateHelper.formatIndonesianDate(
                      attendance.checkIn ?? attendance.createdAt,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isIzin && attendance.alasanIzin != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentWarning.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentWarning.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.accentWarning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Alasan: ${attendance.alasanIzin}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Waktu Presensi Masuk & Keluar
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildTimeRow(
                    context,
                    title: 'Waktu Absen Masuk',
                    timeString: DateHelper.formatTime(attendance.checkIn),
                    icon: Icons.login_rounded,
                    iconColor: AppColors.primary,
                  ),
                  const Divider(height: 24),
                  _buildTimeRow(
                    context,
                    title: 'Waktu Absen Pulang',
                    timeString:
                        attendance.checkOut != null &&
                            attendance.checkOut!.isNotEmpty
                        ? DateHelper.formatTime(attendance.checkOut)
                        : (isIzin
                              ? 'Tidak Diperlukan (Izin)'
                              : 'Belum Absen Pulang'),
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.accentCoral,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Peta Lokasi Google Maps
            const Text(
              'Titik Lokasi Presensi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: targetLatLng,
                        zoom: 16.0,
                      ),
                      markers: markers,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      zoomControlsEnabled: true,
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                    ),
                  ),

                  // Alamat & Koordinat
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              size: 20,
                              color: AppColors.accentCoral,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alamat Terdeteksi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    attendance.checkInAddress != null &&
                                            attendance.checkInAddress!
                                                .trim()
                                                .isNotEmpty
                                        ? attendance.checkInAddress!
                                        : 'Alamat tidak tersedia dalam catatan.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.gps_fixed_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Koordinat: ${targetLatLng.latitude.toStringAsFixed(6)}, ${targetLatLng.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context, {
    required String title,
    required String timeString,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 3),
              Text(
                timeString,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
