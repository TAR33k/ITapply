import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cv_document_search_object.g.dart';

@JsonSerializable()
class CVDocumentSearchObject extends BaseSearchObject {
  int? CandidateId;
  String? FileName;
  bool? IsMain;
  DateTime? UploadDateFrom;
  DateTime? UploadDateTo;

  CVDocumentSearchObject({
    this.CandidateId,
    this.FileName,
    this.IsMain,
    this.UploadDateFrom,
    this.UploadDateTo,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$CVDocumentSearchObjectToJson(this);
}
