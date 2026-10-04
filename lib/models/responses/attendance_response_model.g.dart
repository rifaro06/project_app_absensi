// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceResponseModel _$AttendanceResponseModelFromJson(
  Map<String, dynamic> json,
) => AttendanceResponseModel(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : AttendanceModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceResponseModelToJson(
  AttendanceResponseModel instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};
