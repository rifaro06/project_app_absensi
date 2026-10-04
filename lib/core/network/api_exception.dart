import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Koneksi ke server timeout. Silakan periksa jaringan internet Anda.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String extractedMessage =
            'Terjadi kesalahan pada server ($statusCode).';
        Map<String, dynamic>? validationErrors;

        if (data is Map<String, dynamic>) {
          if (data['message'] != null &&
              data['message'].toString().trim().isNotEmpty) {
            extractedMessage = data['message'].toString();
          }

          if (data['errors'] != null &&
              data['errors'] is Map<String, dynamic>) {
            validationErrors = data['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            validationErrors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else if (value is String) {
                errorList.add(value);
              }
            });
            if (errorList.isNotEmpty) {
              extractedMessage = errorList.join('\n');
            }
          }
        }

        switch (statusCode) {
          case 400:
            return ApiException(
              message: extractedMessage.isNotEmpty
                  ? extractedMessage
                  : 'Permintaan tidak valid (400).',
              statusCode: 400,
              errors: validationErrors,
            );
          case 401:
            return ApiException(
              message: extractedMessage.isNotEmpty
                  ? extractedMessage
                  : 'Sesi Anda telah berakhir. Silakan login kembali.',
              statusCode: 401,
              errors: validationErrors,
            );
          case 403:
            return ApiException(
              message: extractedMessage.isNotEmpty
                  ? extractedMessage
                  : 'Anda tidak memiliki hak akses (403).',
              statusCode: 403,
              errors: validationErrors,
            );
          case 404:
            return ApiException(
              message: extractedMessage.isNotEmpty
                  ? extractedMessage
                  : 'Data atau endpoint tidak ditemukan (404).',
              statusCode: 404,
              errors: validationErrors,
            );
          case 422:
            return ApiException(
              message: extractedMessage.isNotEmpty
                  ? extractedMessage
                  : 'Validasi data gagal (422).',
              statusCode: 422,
              errors: validationErrors,
            );
          case 500:
          default:
            return ApiException(
              message: extractedMessage.isNotEmpty ? extractedMessage : 'Terjadi kendala pada server (500). Coba beberapa saat lagi.',
              statusCode: statusCode,
              errors: validationErrors,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(message: 'Permintaan dibatalkan.');

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message:
              'Terjadi kesalahan yang tidak diketahui: ${error.message ?? 'Unknown error'}',
        );
    }
  }
}
