// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employer _$EmployerFromJson(Map<String, dynamic> json) => Employer(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  companyName: json['companyName'] as String,
  industry: json['industry'] as String?,
  yearsInBusiness: (json['yearsInBusiness'] as num?)?.toInt(),
  description: json['description'] as String?,
  benefits: json['benefits'] as String?,
  address: json['address'] as String?,
  size: json['size'] as String?,
  website: json['website'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactPhone: json['contactPhone'] as String?,
  verificationStatus: $enumDecode(
    _$VerificationStatusEnumMap,
    json['verificationStatus'],
    unknownValue: VerificationStatus.pending,
  ),
  locationId: (json['locationId'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  logo: json['logo'] as String?,
  registrationDate: DateTime.parse(json['registrationDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$EmployerToJson(Employer instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'companyName': instance.companyName,
  'industry': instance.industry,
  'yearsInBusiness': instance.yearsInBusiness,
  'description': instance.description,
  'benefits': instance.benefits,
  'address': instance.address,
  'size': instance.size,
  'website': instance.website,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'locationId': instance.locationId,
  'locationName': instance.locationName,
  'logo': instance.logo,
  'registrationDate': instance.registrationDate.toIso8601String(),
  'isActive': instance.isActive,
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 0,
  VerificationStatus.approved: 1,
  VerificationStatus.rejected: 2,
};
