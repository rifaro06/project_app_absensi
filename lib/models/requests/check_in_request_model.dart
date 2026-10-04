import 'package:json_annotation/json_annotation.dart';

part 'check_in_request_model.g.dart';

@JsonSerializable()
class CheckInRequestModel {
  @JsonKey(name: 'check_in_lat')
  final String checkInLat;

  @JsonKey(name: 'check_in_lng')
  final String checkInLng;

  @JsonKey(name: 'check_in_address')
  final String checkInAddress;

  @JsonKey(name: 'status')
  final String status;

  CheckInRequestModel({
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
  });

  factory CheckInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInRequestModelToJson(this);
}
