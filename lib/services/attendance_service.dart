import 'package:dio/dio.dart';

import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/attendance_model.dart';
import '../models/requests/check_in_request_model.dart';
import '../models/requests/check_out_request_model.dart';
import '../models/requests/izin_request_model.dart';
import '../models/responses/attendance_response_model.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _apiService;

  AttendanceService({ApiService? apiService})
    : _apiService = apiService ?? ApiService(DioClient.instance.dio);

  /// Melakukan Absen Masuk atau Pengajuan Izin
  Future<AttendanceModel?> checkIn({
    required double latitude,
    required double longitude,
    required String address,
    required String status, // 'masuk' atau 'izin'
    String? alasanIzin,
  }) async {
    try {
      final AttendanceResponseModel response;
      if (status == 'izin' && alasanIzin != null) {
        final request = IzinRequestModel(
          checkInLat: latitude.toString(),
          checkInLng: longitude.toString(),
          checkInAddress: address,
          status: status,
          alasanIzin: alasanIzin.trim(),
        );
        response = await _apiService.submitIzin(request);
      } else {
        final request = CheckInRequestModel(
          checkInLat: latitude.toString(),
          checkInLng: longitude.toString(),
          checkInAddress: address,
          status: status,
        );
        response = await _apiService.checkIn(request);
      }

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal melakukan absensi: $e');
    }
  }

  /// Melakukan Absen Pulang / Check-Out
  Future<AttendanceModel?> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final request = CheckOutRequestModel(
        checkOutLat: latitude.toString(),
        checkOutLng: longitude.toString(),
        checkOutLocation: '$latitude, $longitude',
        checkOutAddress: address,
      );

      final response = await _apiService.checkOut(request);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal melakukan absen pulang: $e');
    }
  }

  /// Mengambil seluruh riwayat absensi pengguna
  Future<List<AttendanceModel>> getHistory({String? startDate}) async {
    try {
      final response = await _apiService.getHistory(startDate: startDate);
      return response.data ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal memuat riwayat absensi: $e');
    }
  }

  /// Mengambil data absensi hari ini (jika ada) dari daftar riwayat
  Future<AttendanceModel?> getTodayAttendance() async {
    final history = await getHistory();
    if (history.isEmpty) return null;

    final now = DateTime.now();

    for (final item in history) {
      DateTime? recordDate;
      if (item.checkIn != null) {
        recordDate = DateTime.tryParse(item.checkIn!);
      } else if (item.createdAt != null) {
        recordDate = DateTime.tryParse(item.createdAt!);
      }

      if (recordDate != null) {
        final localDate = recordDate.toLocal();
        if (localDate.year == now.year &&
            localDate.month == now.month &&
            localDate.day == now.day) {
          return item;
        }
      }
    }

    return null;
  }

  /// Menghapus data absensi berdasarkan ID
  Future<bool> deleteAttendance(int id) async {
    try {
      await _apiService.deleteAttendance(id);
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal menghapus data absensi: $e');
    }
  }
}
