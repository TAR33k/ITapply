import 'package:json_annotation/json_annotation.dart';

part 'cv_document.g.dart';
@JsonSerializable()
class CVDocument {
  final int id;
  final int candidateId;
  final String? candidateName;
  final String fileName;
  final String fileContent;
  final bool isMain;
  final DateTime uploadDate;

  CVDocument({
    required this.id,
    required this.candidateId,
    this.candidateName,
    required this.fileName,
    required this.fileContent,
    required this.isMain,
    required this.uploadDate,
  });

  factory CVDocument.fromJson(Map<String, dynamic> json) => _$CVDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$CVDocumentToJson(this);
}