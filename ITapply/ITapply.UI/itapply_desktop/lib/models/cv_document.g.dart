// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVDocument _$CVDocumentFromJson(Map<String, dynamic> json) => CVDocument(
  id: (json['id'] as num).toInt(),
  candidateId: (json['candidateId'] as num).toInt(),
  candidateName: json['candidateName'] as String?,
  fileName: json['fileName'] as String,
  fileContent: json['fileContent'] as String,
  isMain: json['isMain'] as bool,
  uploadDate: DateTime.parse(json['uploadDate'] as String),
);

Map<String, dynamic> _$CVDocumentToJson(CVDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateId': instance.candidateId,
      'candidateName': instance.candidateName,
      'fileName': instance.fileName,
      'fileContent': instance.fileContent,
      'isMain': instance.isMain,
      'uploadDate': instance.uploadDate.toIso8601String(),
    };
