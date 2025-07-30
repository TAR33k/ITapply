import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_search_object.g.dart';

@JsonSerializable()
class ReviewSearchObject extends BaseSearchObject {
  int? CandidateId;
  int? EmployerId;
  String? CandidateName;
  String? CompanyName;
  int? MinRating;
  int? MaxRating;
  @JsonKey(name: 'Relationship', toJson: _reviewRelationshipToJson)
  ReviewRelationship? relationship;
  @JsonKey(name: 'ModerationStatus', toJson: _moderationStatusToJson)
  ModerationStatus? moderationStatus;
  DateTime? ReviewDateFrom;
  DateTime? ReviewDateTo;

  ReviewSearchObject({
    this.CandidateId,
    this.EmployerId,
    this.CandidateName,
    this.CompanyName,
    this.MinRating,
    this.MaxRating,
    this.relationship,
    this.moderationStatus,
    this.ReviewDateFrom,
    this.ReviewDateTo,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$ReviewSearchObjectToJson(this);
}

int? _reviewRelationshipToJson(ReviewRelationship? relationship) => relationship?.index;
int? _moderationStatusToJson(ModerationStatus? status) => status?.index;
