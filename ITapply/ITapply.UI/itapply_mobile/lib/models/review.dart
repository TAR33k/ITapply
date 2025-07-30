import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';
@JsonSerializable(explicitToJson: true)
class Review {
  final int id;
  final int candidateId;
  final String? candidateName;
  final int employerId;
  final String? companyName;
  final int rating;
  final String? comment;
  @JsonKey(unknownEnumValue: ReviewRelationship.formerEmployee)
  final ReviewRelationship relationship;
  final String? position;
  @JsonKey(unknownEnumValue: ModerationStatus.pending)
  final ModerationStatus moderationStatus;
  final DateTime reviewDate;

  Review({
    required this.id,
    required this.candidateId,
    this.candidateName,
    required this.employerId,
    this.companyName,
    required this.rating,
    this.comment,
    required this.relationship,
    this.position,
    required this.moderationStatus,
    required this.reviewDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}