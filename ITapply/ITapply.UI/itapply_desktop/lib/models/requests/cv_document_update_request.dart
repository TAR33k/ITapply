import 'package:json_annotation/json_annotation.dart';

part 'cv_document_update_request.g.dart';

@JsonSerializable()
class CVDocumentUpdateRequest {
  final String? fileName;
  final String? fileContent;
  final bool? isMain;

  CVDocumentUpdateRequest({
    this.fileName,
    this.fileContent,
    this.isMain,
  });

  factory CVDocumentUpdateRequest.fromJson(Map<String, dynamic> json) => _$CVDocumentUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CVDocumentUpdateRequestToJson(this);
}