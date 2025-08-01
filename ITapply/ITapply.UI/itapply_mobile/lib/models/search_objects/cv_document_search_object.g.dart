// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_document_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
CVDocumentSearchObject _$CVDocumentSearchObjectFromJson(
  Map<String, dynamic> json,
) => CVDocumentSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  FileName: json['FileName'] as String?,
  IsMain: json['IsMain'] as bool?,
  UploadDateFrom: json['UploadDateFrom'] == null
      ? null
      : DateTime.parse(json['UploadDateFrom'] as String),
  UploadDateTo: json['UploadDateTo'] == null
      ? null
      : DateTime.parse(json['UploadDateTo'] as String),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$CVDocumentSearchObjectToJson(
  CVDocumentSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'FileName': instance.FileName,
  'IsMain': instance.IsMain,
  'UploadDateFrom': instance.UploadDateFrom?.toIso8601String(),
  'UploadDateTo': instance.UploadDateTo?.toIso8601String(),
};
