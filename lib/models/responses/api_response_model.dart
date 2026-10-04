import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

@JsonSerializable()
class ApiResponseModel {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final dynamic data;

  ApiResponseModel({this.message, this.data});

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseModelToJson(this);
}
