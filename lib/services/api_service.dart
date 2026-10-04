import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_response_model.dart';
import '../models/requests/check_in_request_model.dart';
import '../models/requests/check_out_request_model.dart';
import '../models/requests/izin_request_model.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/profile_update_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/api_response_model.dart';
import '../models/responses/attendance_response_model.dart';
import '../models/responses/history_response_model.dart';
import '../models/responses/profile_response_model.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  @POST('/register')
  Future<AuthResponseModel> register(@Body() RegisterRequestModel request);

  @POST('/login')
  Future<AuthResponseModel> login(@Body() LoginRequestModel request);

  @POST('/absen/check-in')
  Future<AttendanceResponseModel> checkIn(
    @Body() CheckInRequestModel request, {
    @Header('Authorization') String? token,
  });

  @POST('/absen/check-in')
  Future<AttendanceResponseModel> submitIzin(
    @Body() IzinRequestModel request, {
    @Header('Authorization') String? token,
  });

  @POST('/absen/check-out')
  Future<AttendanceResponseModel> checkOut(
    @Body() CheckOutRequestModel request, {
    @Header('Authorization') String? token,
  });

  @GET('/absen/history')
  Future<HistoryResponseModel> getHistory({
    @Query('start') String? startDate,
    @Header('Authorization') String? token,
  });

  @GET('/profile')
  Future<ProfileResponseModel> getProfile({
    @Header('Authorization') String? token,
  });

  @PUT('/profile')
  Future<ProfileResponseModel> updateProfile(
    @Body() ProfileUpdateRequestModel request, {
    @Header('Authorization') String? token,
  });

  @DELETE('/absen/{id}')
  Future<ApiResponseModel> deleteAttendance(
    @Path('id') int id, {
    @Header('Authorization') String? token,
  });
}
