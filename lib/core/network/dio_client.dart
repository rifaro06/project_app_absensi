import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;

  // Callback opsional saat token expired (401)
  static void Function()? onUnauthorized;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor: Otomatis menyisipkan Token & Handle 401
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari storage jika header Authorization belum ada
          if (!options.headers.containsKey('Authorization') ||
              options.headers['Authorization'] == null) {
            final token = await StorageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Sesi kedaluwarsa: bersihkan storage & picu callback redirect jika ada
            await StorageService.clearSession();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );

    // Logging di konsol debug untuk mempermudah pengecekan request
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }
}
