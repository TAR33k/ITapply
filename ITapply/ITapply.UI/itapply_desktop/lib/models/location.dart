import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';
@JsonSerializable()
class Location {
  final int id;
  final String city;
  final String country;

  Location({required this.id, required this.city, required this.country});

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}