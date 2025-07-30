import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employer.g.dart';
@JsonSerializable(explicitToJson: true)
class Employer {
  final int id;
  final String email;
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
  @JsonKey(unknownEnumValue: VerificationStatus.pending)
  final VerificationStatus verificationStatus;
  final int? locationId;
  final String? locationName;
  final String? logo;
  final DateTime registrationDate;
  final bool isActive;

  Employer({
    required this.id,
    required this.email,
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
    required this.verificationStatus,
    this.locationId,
    this.locationName,
    this.logo,
    required this.registrationDate,
    required this.isActive,
  });

  factory Employer.fromJson(Map<String, dynamic> json) => _$EmployerFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerToJson(this);
}
