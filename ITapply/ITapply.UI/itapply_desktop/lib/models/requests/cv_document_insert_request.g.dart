// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_document_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVDocumentInsertRequest _$CVDocumentInsertRequestFromJson(
  Map<String, dynamic> json,
) => CVDocumentInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  fileName: json['fileName'] as String,
  fileContent: json['fileContent'] as String,
  isMain: json['isMain'] as bool?,
);

Map<String, dynamic> _$CVDocumentInsertRequestToJson(
  CVDocumentInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'fileName': instance.fileName,
  'fileContent': instance.fileContent,
  'isMain': instance.isMain,
};
