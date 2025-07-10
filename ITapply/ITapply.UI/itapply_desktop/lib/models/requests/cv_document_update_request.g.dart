// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_document_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVDocumentUpdateRequest _$CVDocumentUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CVDocumentUpdateRequest(
  fileName: json['fileName'] as String?,
  fileContent: json['fileContent'] as String?,
  isMain: json['isMain'] as bool?,
);

Map<String, dynamic> _$CVDocumentUpdateRequestToJson(
  CVDocumentUpdateRequest instance,
) => <String, dynamic>{
  'fileName': instance.fileName,
  'fileContent': instance.fileContent,
  'isMain': instance.isMain,
};
