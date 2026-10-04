import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthData {
  @JsonKey(name: 'token')
  final String? token;

  @JsonKey(name: 'user')
  final UserModel? user;

  AuthData({this.token, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class AuthResponseModel {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final AuthData? data;

  AuthResponseModel({required this.message, this.data});

  // Getter helper agar UI & Service tetap kompatibel
  String? get token => data?.token;
  UserModel? get user => data?.user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
