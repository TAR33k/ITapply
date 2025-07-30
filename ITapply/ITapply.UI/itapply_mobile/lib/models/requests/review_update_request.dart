import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_update_request.g.dart';

@JsonSerializable()
class ReviewUpdateRequest {
  final int? rating;
  final String? comment;
  @JsonKey(toJson: _reviewRelationshipToJson)
  final ReviewRelationship? relationship;
  final String? position;
  @JsonKey(toJson: _moderationStatusToJson)
  final ModerationStatus? moderationStatus;

  ReviewUpdateRequest({
    this.rating,
    this.comment,
    this.relationship,
    this.position,
    this.moderationStatus,
  });

  factory ReviewUpdateRequest.fromJson(Map<String, dynamic> json) => _$ReviewUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewUpdateRequestToJson(this);
}

int? _reviewRelationshipToJson(ReviewRelationship? relationship) => relationship?.index;
int? _moderationStatusToJson(ModerationStatus? status) => status?.index;
