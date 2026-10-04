import 'package:json_annotation/json_annotation.dart';

part 'profile_update_request_model.g.dart';

@JsonSerializable()
class ProfileUpdateRequestModel {
  @JsonKey(name: 'name')
  final String name;

  ProfileUpdateRequestModel({required this.name});

  factory ProfileUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestModelToJson(this);
}
