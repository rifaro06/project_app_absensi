import 'package:json_annotation/json_annotation.dart';

import '../user_model.dart';

part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final UserModel? data;

  ProfileResponseModel({this.message, this.data});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);
}
