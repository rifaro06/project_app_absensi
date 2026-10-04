import 'package:json_annotation/json_annotation.dart';

part 'check_out_request_model.g.dart';

@JsonSerializable()
class CheckOutRequestModel {
  @JsonKey(name: 'check_out_lat')
  final String checkOutLat;

  @JsonKey(name: 'check_out_lng')
  final String checkOutLng;

  @JsonKey(name: 'check_out_location')
  final String checkOutLocation;

  @JsonKey(name: 'check_out_address')
  final String checkOutAddress;

  CheckOutRequestModel({
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkOutLocation,
    required this.checkOutAddress,
  });

  factory CheckOutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CheckOutRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckOutRequestModelToJson(this);
}
