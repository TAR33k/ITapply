import 'package:json_annotation/json_annotation.dart';

part 'employer_update_request.g.dart';

@JsonSerializable()
class EmployerUpdateRequest {
  final String companyName;
  final String? industry;
  final int? yearsInBusiness;
  final String? description;
  final String? benefits;
  final String? address;
  final String? size;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;
  final int? locationId;
  final String? logo;

  EmployerUpdateRequest({
    required this.companyName,
    this.industry,
    this.yearsInBusiness,
    this.description,
    this.benefits,
    this.address,
    this.size,
    this.website,
    this.contactEmail,
    this.contactPhone,
    this.locationId,
    this.logo,
  });

  factory EmployerUpdateRequest.fromJson(Map<String, dynamic> json) => _$EmployerUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerUpdateRequestToJson(this);
}
