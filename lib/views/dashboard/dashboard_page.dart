import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart';
import 'widgets/attendance_status_card.dart';
import 'widgets/izin_dialog.dart';
import 'widgets/live_clock_card.dart';
import 'widgets/map_preview_card.dart';
import '../../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _attendanceService = AttendanceService();

  String _userName = '';
  String? _userPhotoPath;
  AttendanceModel? _todayAttendance;
  LocationResult? _currentLocation;

  bool _isLoadingData = false;
  bool _isLoadingLocation = false;
  bool _isActionRunning = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);

    // Ambil nama user tersimpan
    final name = await StorageService.getUserName();
    final uid = await StorageService.getUserId() ?? 0;
    final photo = uid > 0 ? await StorageService.getUserPhoto(uid) : null;
    if (mounted) {
      setState(() {
        _userName = name ?? 'Peserta PPKD';
        _userPhotoPath = photo;
      });
    }

    // Ambil lokasi dan status absensi paralel
    await Future.wait([_fetchLocation(), _fetchTodayAttendance()]);

    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _fetchTodayAttendance() async {
    try {
      final today = await _attendanceService.getTodayAttendance();
      if (mounted) {
        setState(() => _todayAttendance = today);
      }
    } catch (e) {
      // Jangan crash jika gagal memuat riwayat, tampilkan snackbar jika perlu
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await LocationService.getCurrentLocationWithAddress();
      if (mounted) {
        setState(() => _currentLocation = loc);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // Absen Masuk
  Future<void> _handleCheckIn() async {
    if (_isActionRunning) return;

    if (_currentLocation == null) {
      await _fetchLocation();
      if (!mounted) return;
      if (_currentLocation == null) {
        AppSnackbar.showError(
          context,
          'Tidak dapat mendeteksi lokasi GPS Anda.',
        );
        return;
      }
    }

    setState(() => _isActionRunning = true);

    try {
      await _attendanceService.checkIn(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        address: _currentLocation!.address,
        status: 'masuk',
      );

      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Presensi masuk berhasil dicatat!');
      await _fetchTodayAttendance();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  // Absen Pulang
  Future<void> _handleCheckOut() async {
    if (_isActionRunning) return;

    if (_currentLocation == null) {
      await _fetchLocation();
      if (!mounted) return;
      if (_currentLocation == null) {
        AppSnackbar.showError(
          context,
          'Tidak dapat mendeteksi lokasi GPS Anda.',
        );
        return;
      }
    }

    setState(() => _isActionRunning = true);

    try {
      await _attendanceService.checkOut(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        address: _currentLocation!.address,
      );

      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Presensi keluar berhasil dicatat!');
      await _fetchTodayAttendance();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  // Pengajuan Izin
  void _openIzinModal() {
    IzinDialog.show(
      context,
      onSubmit: (reason) async {
        if (_currentLocation == null) {
          await _fetchLocation();
        }

        final lat = _currentLocation?.latitude ?? -6.2088;
        final lng = _currentLocation?.longitude ?? 106.8456;
        final addr = _currentLocation?.address ?? 'Jakarta';

        await _attendanceService.checkIn(
          latitude: lat,
          longitude: lng,
          address: addr,
          status: 'izin',
          alasanIzin: reason,
        );

        if (!mounted) return;
        AppSnackbar.showSuccess(context, 'Pengajuan izin berhasil dicatat!!');
        await _fetchTodayAttendance();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _todayAttendance != null;
    final isIzin = hasData && _todayAttendance!.isIzin;
    final isCheckedIn = hasData && _todayAttendance!.isCheckedIn;
    final isCheckedOut = hasData && _todayAttendance!.isCheckedOut;

    // Logika Tombol
    final canCheckIn = !hasData || (!isCheckedIn && !isIzin);
    final canCheckOut = hasData && isCheckedIn && !isCheckedOut && !isIzin;
    final canIzin = !hasData;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Presensi Digital PPKD',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                ),
                tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                onPressed: () => toggleAppTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Halaman',
            onPressed: _isLoadingData ? null : _loadInitialData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Live Clock Card
              LiveClockCard(userName: _userName, photoPath: _userPhotoPath),
              const SizedBox(height: 16),

              // 2. Status Kehadiran Hari Ini
              AttendanceStatusCard(
                todayAttendance: _todayAttendance,
                isLoading: _isLoadingData,
              ),
              const SizedBox(height: 16),

              // 3. Peta Interaktif & Lokasi Aktual
              MapPreviewCard(
                location: _currentLocation,
                isLoading: _isLoadingLocation,
                onRefresh: _fetchLocation,
              ),
              const SizedBox(height: 24),

              // 4. Tombol Aksi Absensi
              const Text(
                'Aksi Presensi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Tombol Masuk
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isActionRunning
                          ? null
                          : () {
                              if (canCheckIn) {
                                _handleCheckIn();
                              } else {
                                if (isCheckedOut) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Anda sudah menyelesaikan presensi masuk dan pulang hari ini.',
                                  );
                                } else if (isCheckedIn) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Anda sudah melakukan presensi masuk hari ini.',
                                  );
                                } else if (isIzin) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Anda sudah tercatat izin untuk hari ini.',
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text('Absen Masuk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canCheckIn
                            ? AppColors.primary
                            : AppColors.primary.withAlpha(120),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Keluar
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isActionRunning
                          ? null
                          : () {
                              if (canCheckOut) {
                                _handleCheckOut();
                              } else {
                                if (isCheckedOut) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Anda sudah menyelesaikan presensi pulang hari ini.',
                                  );
                                } else if (!isCheckedIn) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Silakan lakukan presensi masuk terlebih dahulu sebelum absen pulang.',
                                  );
                                } else if (isIzin) {
                                  AppSnackbar.showInfo(
                                    context,
                                    'Anda sudah tercatat izin hari ini, tidak perlu presensi pulang.',
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Absen Pulang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canCheckOut
                            ? AppColors.accentCoral
                            : AppColors.accentCoral.withAlpha(120),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tombol Izin (Hanya aktif jika belum absen)
              OutlinedButton.icon(
                onPressed: _isActionRunning
                    ? null
                    : () {
                        if (canIzin) {
                          _openIzinModal();
                        } else {
                          AppSnackbar.showInfo(
                            context,
                            'Pengajuan izin hanya dapat dilakukan jika belum memiliki catatan presensi hari ini.',
                          );
                        }
                      },
                icon: const Icon(Icons.event_note_rounded, size: 18),
                label: const Text('Ajukan Izin / Sakit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: canIzin
                      ? AppColors.primary
                      : AppColors.primary.withAlpha(120),
                  side: BorderSide(
                    color: canIzin
                        ? AppColors.primaryLight
                        : AppColors.primaryLight.withAlpha(100),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
