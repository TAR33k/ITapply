import 'package:json_annotation/json_annotation.dart';

part 'location_update_request.g.dart';

@JsonSerializable()
class LocationUpdateRequest {
  final String city;
  final String country;

  LocationUpdateRequest({required this.city, required this.country});

  factory LocationUpdateRequest.fromJson(Map<String, dynamic> json) => _$LocationUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LocationUpdateRequestToJson(this);
}
