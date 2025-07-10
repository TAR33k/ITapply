// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  candidateId: (json['candidateId'] as num).toInt(),
  candidateName: json['candidateName'] as String?,
  employerId: (json['employerId'] as num).toInt(),
  companyName: json['companyName'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  relationship: $enumDecode(
    _$ReviewRelationshipEnumMap,
    json['relationship'],
    unknownValue: ReviewRelationship.formerEmployee,
  ),
  position: json['position'] as String?,
  moderationStatus: $enumDecode(
    _$ModerationStatusEnumMap,
    json['moderationStatus'],
    unknownValue: ModerationStatus.pending,
  ),
  reviewDate: DateTime.parse(json['reviewDate'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'candidateId': instance.candidateId,
  'candidateName': instance.candidateName,
  'employerId': instance.employerId,
  'companyName': instance.companyName,
  'rating': instance.rating,
  'comment': instance.comment,
  'relationship': _$ReviewRelationshipEnumMap[instance.relationship]!,
  'position': instance.position,
  'moderationStatus': _$ModerationStatusEnumMap[instance.moderationStatus]!,
  'reviewDate': instance.reviewDate.toIso8601String(),
};

const _$ReviewRelationshipEnumMap = {
  ReviewRelationship.currentEmployee: 'currentEmployee',
  ReviewRelationship.formerEmployee: 'formerEmployee',
  ReviewRelationship.interviewee: 'interviewee',
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 'pending',
  ModerationStatus.approved: 'approved',
  ModerationStatus.rejected: 'rejected',
};
