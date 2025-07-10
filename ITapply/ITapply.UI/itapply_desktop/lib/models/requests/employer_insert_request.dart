import 'package:json_annotation/json_annotation.dart';

part 'employer_insert_request.g.dart';

@JsonSerializable()
class EmployerInsertRequest {
  final int userId;
  final String companyName;
  final String industry;
  final int yearsInBusiness;
  final String description;
  final String benefits;
  final String address;
  final String size;
  final String website;
  final String contactEmail;
  final String contactPhone;
  final int? locationId;
  final String? logo;

  EmployerInsertRequest({
    required this.userId,
    required this.companyName,
    required this.industry,
    required this.yearsInBusiness,
    required this.description,
    required this.benefits,
    required this.address,
    required this.size,
    required this.website,
    required this.contactEmail,
    required this.contactPhone,
    this.locationId,
    this.logo,
  });

  factory EmployerInsertRequest.fromJson(Map<String, dynamic> json) => _$EmployerInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerInsertRequestToJson(this);
}