import 'package:dio/dio.dart';

import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/storage/storage_service.dart';
import '../models/requests/profile_update_request_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService({ApiService? apiService})
    : _apiService = apiService ?? ApiService(DioClient.instance.dio);

  /// Mengambil data profil user terbaru dari API
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      final user = response.data;
      if (user != null) {
        // Sinkronisasi data ke storage lokal
        await StorageService.saveUserData(
          id: user.id,
          name: user.name,
          email: user.email,
        );
        return user;
      }
      throw ApiException(message: 'Format data profil tidak valid.');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal memuat profil: $e');
    }
  }

  /// Memperbarui nama pengguna
  Future<UserModel> updateProfileName(String name) async {
    try {
      final request = ProfileUpdateRequestModel(name: name.trim());
      final response = await _apiService.updateProfile(request);
      final user = response.data;
      if (user != null) {
        await StorageService.updateUserName(user.name);
        return user;
      }
      throw ApiException(message: 'Format respon edit profil tidak valid.');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Gagal memperbarui profil: $e');
    }
  }
}
