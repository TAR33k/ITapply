import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_insert_request.g.dart';

@JsonSerializable()
class ReviewInsertRequest {
  final int candidateId;
  final int employerId;
  final int rating;
  final String comment;
  @JsonKey(toJson: _reviewRelationshipToJson)
  final ReviewRelationship relationship;
  final String position;

  ReviewInsertRequest({
    required this.candidateId,
    required this.employerId,
    required this.rating,
    required this.comment,
    required this.relationship,
    required this.position,
  });

  factory ReviewInsertRequest.fromJson(Map<String, dynamic> json) => _$ReviewInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewInsertRequestToJson(this);
}

int _reviewRelationshipToJson(ReviewRelationship relationship) => relationship.index;
