// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerUpdateRequest _$EmployerUpdateRequestFromJson(
  Map<String, dynamic> json,
) => EmployerUpdateRequest(
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
  locationId: (json['locationId'] as num?)?.toInt(),
  logo: json['logo'] as String?,
);

Map<String, dynamic> _$EmployerUpdateRequestToJson(
  EmployerUpdateRequest instance,
) => <String, dynamic>{
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
  'locationId': instance.locationId,
  'logo': instance.logo,
};
