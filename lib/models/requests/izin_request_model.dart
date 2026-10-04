import 'package:json_annotation/json_annotation.dart';

part 'izin_request_model.g.dart';

@JsonSerializable()
class IzinRequestModel {
  @JsonKey(name: 'check_in_lat')
  final String checkInLat;

  @JsonKey(name: 'check_in_lng')
  final String checkInLng;

  @JsonKey(name: 'check_in_address')
  final String checkInAddress;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'alasan_izin')
  final String alasanIzin;

  IzinRequestModel({
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinRequestModel.fromJson(Map<String, dynamic> json) =>
      _$IzinRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$IzinRequestModelToJson(this);
}
