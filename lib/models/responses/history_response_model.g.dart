// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryResponseModel _$HistoryResponseModelFromJson(
  Map<String, dynamic> json,
) => HistoryResponseModel(
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HistoryResponseModelToJson(
  HistoryResponseModel instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};
