import 'package:json_annotation/json_annotation.dart';

part 'cv_document_insert_request.g.dart';

@JsonSerializable()
class CVDocumentInsertRequest {
  final int candidateId;
  final String fileName;
  final String fileContent;
  final bool? isMain;

  CVDocumentInsertRequest({
    required this.candidateId,
    required this.fileName,
    required this.fileContent,
    this.isMain,
  });

  factory CVDocumentInsertRequest.fromJson(Map<String, dynamic> json) => _$CVDocumentInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CVDocumentInsertRequestToJson(this);
}