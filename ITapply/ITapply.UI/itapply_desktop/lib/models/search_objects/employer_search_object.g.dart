// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerSearchObject _$EmployerSearchObjectFromJson(
  Map<String, dynamic> json,
) => EmployerSearchObject(
  CompanyName: json['CompanyName'] as String?,
  Industry: json['Industry'] as String?,
  MinYearsInBusiness: (json['MinYearsInBusiness'] as num?)?.toInt(),
  MaxYearsInBusiness: (json['MaxYearsInBusiness'] as num?)?.toInt(),
  LocationId: (json['LocationId'] as num?)?.toInt(),
  ContactEmail: json['ContactEmail'] as String?,
  verificationStatus: $enumDecodeNullable(
    _$VerificationStatusEnumMap,
    json['VerificationStatus'],
  ),
  Email: json['Email'] as String?,
  IsActive: json['IsActive'] as bool?,
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$EmployerSearchObjectToJson(
  EmployerSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CompanyName': instance.CompanyName,
  'Industry': instance.Industry,
  'MinYearsInBusiness': instance.MinYearsInBusiness,
  'MaxYearsInBusiness': instance.MaxYearsInBusiness,
  'LocationId': instance.LocationId,
  'ContactEmail': instance.ContactEmail,
  'VerificationStatus': _verificationStatusToJson(instance.verificationStatus),
  'Email': instance.Email,
  'IsActive': instance.IsActive,
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 0,
  VerificationStatus.approved: 1,
  VerificationStatus.rejected: 2,
};
