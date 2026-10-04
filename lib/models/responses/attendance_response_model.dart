import 'package:json_annotation/json_annotation.dart';

import '../attendance_model.dart';

part 'attendance_response_model.g.dart';

@JsonSerializable()
class AttendanceResponseModel {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final AttendanceModel? data;

  AttendanceResponseModel({this.message, this.data});

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceResponseModelToJson(this);
}
