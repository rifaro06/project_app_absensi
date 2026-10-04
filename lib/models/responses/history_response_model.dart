import 'package:json_annotation/json_annotation.dart';

import '../attendance_model.dart';

part 'history_response_model.g.dart';

@JsonSerializable()
class HistoryResponseModel {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final List<AttendanceModel>? data;

  HistoryResponseModel({this.message, this.data});

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryResponseModelToJson(this);
}
