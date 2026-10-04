import 'package:dio/dio.dart';

import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/storage/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService(DioClient.instance.dio);

  /// Melakukan Login ke API PPKD
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(
        email: email.trim(),
        password: password,
      );

      final authResponse = await _apiService.login(request);

      // Simpan session jika token tersedia
      if (authResponse.token != null && authResponse.token!.isNotEmpty) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await StorageService.saveUserData(
            id: authResponse.user!.id,
            name: authResponse.user!.name,
            email: authResponse.user!.email,
          );
        }
      }

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan: $e');
    }
  }

  /// Melakukan Registrasi User baru
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequestModel(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      final authResponse = await _apiService.register(request);

      // Jika registrasi langsung mengembalikan token, simpan session
      if (authResponse.token != null && authResponse.token!.isNotEmpty) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await StorageService.saveUserData(
            id: authResponse.user!.id,
            name: authResponse.user!.name,
            email: authResponse.user!.email,
          );
        }
      }

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan: $e');
    }
  }

  /// Keluar dari aplikasi & hapus data session
  Future<void> logout() async {
    await StorageService.clearSession();
  }

  /// Cek apakah session user masih valid
  Future<bool> checkSession() async {
    return await StorageService.isLoggedIn();
  }
}
