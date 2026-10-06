import 'package:flutter_test/flutter_test.dart';
import 'package:project_app_absensi/models/attendance_model.dart';
import 'package:project_app_absensi/models/auth_response_model.dart';
import 'package:project_app_absensi/models/user_model.dart';
import 'package:project_app_absensi/models/requests/check_in_request_model.dart';
import 'package:project_app_absensi/models/requests/check_out_request_model.dart';
import 'package:project_app_absensi/models/requests/izin_request_model.dart';
import 'package:project_app_absensi/models/requests/login_request_model.dart';
import 'package:project_app_absensi/models/requests/profile_update_request_model.dart';
import 'package:project_app_absensi/models/requests/register_request_model.dart';
import 'package:project_app_absensi/models/responses/api_response_model.dart';
import 'package:project_app_absensi/models/responses/attendance_response_model.dart';
import 'package:project_app_absensi/models/responses/history_response_model.dart';
import 'package:project_app_absensi/core/utils/date_helper.dart';
import 'package:project_app_absensi/models/responses/profile_response_model.dart';

void main() {
  group('Model Tests', () {
    test('UserModel.fromJson and toJson create valid object', () {
      final json = {
        'id': 1,
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'created_at': '2026-10-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'Budi Santoso');
      expect(user.email, 'budi@example.com');
      expect(user.toJson()['name'], 'Budi Santoso');
    });

    test(
      'AuthResponseModel.fromJson handles success response with token and user',
      () {
        final json = {
          'message': 'Login berhasil',
          'data': {
            'token': 'mock_token_123',
            'user': {
              'id': 10,
              'name': 'Siti Rahma',
              'email': 'siti@example.com',
            },
          },
        };

        final auth = AuthResponseModel.fromJson(json);
        expect(auth.message, 'Login berhasil');
        expect(auth.token, 'mock_token_123');
        expect(auth.user?.name, 'Siti Rahma');
      },
    );

    test('AttendanceModel.fromJson calculates status flags correctly', () {
      final masukJson = {
        'id': 5,
        'check_in': '2026-10-03 08:00:00',
        'status': 'masuk',
        'check_in_lat': -6.2,
        'check_in_lng': 106.8,
      };

      final masuk = AttendanceModel.fromJson(masukJson);
      expect(masuk.isCheckedIn, true);
      expect(masuk.isCheckedOut, false);
      expect(masuk.isIzin, false);
      expect(masuk.checkInLat, -6.2);

      final izinJson = {
        'id': 6,
        'check_in': '2026-10-03 08:00:00',
        'status': 'izin',
        'alasan_izin': 'Izin Sakit',
      };

      final izin = AttendanceModel.fromJson(izinJson);
      expect(izin.isIzin, true);
      expect(izin.alasanIzin, 'Izin Sakit');
    });

    test('Request models toJson serialize correctly', () {
      final loginReq = LoginRequestModel(
        email: 'test@mail.com',
        password: 'password123',
      );
      expect(loginReq.toJson()['email'], 'test@mail.com');

      final regReq = RegisterRequestModel(
        name: 'Andi',
        email: 'andi@mail.com',
        password: '123',
      );
      expect(regReq.toJson()['name'], 'Andi');

      final checkInReq = CheckInRequestModel(
        checkInLat: '-6.2',
        checkInLng: '106.8',
        checkInAddress: 'Jakarta',
        status: 'masuk',
      );
      expect(checkInReq.toJson()['status'], 'masuk');

      final izinReq = IzinRequestModel(
        checkInLat: '-6.2',
        checkInLng: '106.8',
        checkInAddress: 'Jakarta',
        status: 'izin',
        alasanIzin: 'Sakit flu',
      );
      expect(izinReq.toJson()['alasan_izin'], 'Sakit flu');

      final checkOutReq = CheckOutRequestModel(
        checkOutLat: '-6.2',
        checkOutLng: '106.8',
        checkOutLocation: '-6.2, 106.8',
        checkOutAddress: 'Jakarta',
      );
      expect(checkOutReq.toJson()['check_out_location'], '-6.2, 106.8');

      final profileReq = ProfileUpdateRequestModel(name: 'Budi Baru');
      expect(profileReq.toJson()['name'], 'Budi Baru');
    });

    test('Response wrapper models parse correctly', () {
      final attRes = AttendanceResponseModel.fromJson({
        'message': 'Presensi berhasil',
        'data': {
          'id': 100,
          'status': 'masuk',
          'check_in': '2026-10-03 09:00:00',
        },
      });
      expect(attRes.message, 'Presensi berhasil');
      expect(attRes.data?.id, 100);

      final histRes = HistoryResponseModel.fromJson({
        'message': 'Riwayat berhasil',
        'data': [
          {'id': 1, 'status': 'masuk'},
          {'id': 2, 'status': 'izin'},
        ],
      });
      expect(histRes.data?.length, 2);

      final profRes = ProfileResponseModel.fromJson({
        'message': 'Profil berhasil',
        'data': {'id': 1, 'name': 'User A', 'email': 'a@a.com'},
      });
      expect(profRes.data?.name, 'User A');

      final apiRes = ApiResponseModel.fromJson({
        'message': 'Sukses dihapus',
        'data': true,
      });
      expect(apiRes.message, 'Sukses dihapus');
    });

    test('DateHelper correctly parses UTC date strings from MySQL/Laravel', () {
      // 00:06:00 UTC should be 7 hours ahead in local WIB (07:06)
      final dt = DateHelper.parseDateTime('2026-10-06 00:06:00');
      expect(dt, isNotNull);
      // In local time, dt should represent the exact instant in local zone
      final formattedTime = DateHelper.formatTime('2026-10-06 00:06:00');
      expect(formattedTime.contains('WIB'), true);

      // Time only format
      final formattedTimeOnly = DateHelper.formatTime('00:06:00');
      expect(formattedTimeOnly.contains('WIB'), true);

      // Null handling
      expect(DateHelper.formatTime(null), '--:--');
      expect(DateHelper.formatTime('null'), '--:--');
      expect(DateHelper.formatIndonesianDate(null), '-');
    });
  });
}
