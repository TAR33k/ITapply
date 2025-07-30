import 'package:json_annotation/json_annotation.dart';

part 'location_insert_request.g.dart';

@JsonSerializable()
class LocationInsertRequest {
  final String city;
  final String country;

  LocationInsertRequest({required this.city, required this.country});

  factory LocationInsertRequest.fromJson(Map<String, dynamic> json) => _$LocationInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LocationInsertRequestToJson(this);
}
