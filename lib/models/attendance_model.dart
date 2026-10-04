import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  @JsonKey(name: 'id', fromJson: _idFromJson)
  final int id;

  @JsonKey(name: 'user_id', fromJson: _nullableIdFromJson)
  final int? userId;

  @JsonKey(name: 'check_in')
  final String? checkIn;

  @JsonKey(name: 'check_in_location')
  final String? checkInLocation;

  @JsonKey(name: 'check_in_address')
  final String? checkInAddress;

  @JsonKey(name: 'check_out')
  final String? checkOut;

  @JsonKey(name: 'check_out_location')
  final String? checkOutLocation;

  @JsonKey(name: 'check_out_address')
  final String? checkOutAddress;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'alasan_izin')
  final String? alasanIzin;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'check_in_lat', fromJson: _parseDouble)
  final double? checkInLat;

  @JsonKey(name: 'check_in_lng', fromJson: _parseDouble)
  final double? checkInLng;

  @JsonKey(name: 'check_out_lat', fromJson: _parseDouble)
  final double? checkOutLat;

  @JsonKey(name: 'check_out_lng', fromJson: _parseDouble)
  final double? checkOutLng;

  AttendanceModel({
    required this.id,
    this.userId,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  static int _idFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static int? _nullableIdFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  bool get isIzin =>
      (status?.toLowerCase() == 'izin') ||
      (alasanIzin != null && alasanIzin!.trim().isNotEmpty);

  bool get isCheckedIn => checkIn != null && checkIn!.trim().isNotEmpty;

  bool get isCheckedOut => checkOut != null && checkOut!.trim().isNotEmpty;
}
