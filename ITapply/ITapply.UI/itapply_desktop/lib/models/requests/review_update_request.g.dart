// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewUpdateRequest _$ReviewUpdateRequestFromJson(Map<String, dynamic> json) =>
    ReviewUpdateRequest(
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      relationship: $enumDecodeNullable(
        _$ReviewRelationshipEnumMap,
        json['relationship'],
      ),
      position: json['position'] as String?,
      moderationStatus: $enumDecodeNullable(
        _$ModerationStatusEnumMap,
        json['moderationStatus'],
      ),
    );

Map<String, dynamic> _$ReviewUpdateRequestToJson(
  ReviewUpdateRequest instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'comment': instance.comment,
  'relationship': _reviewRelationshipToJson(instance.relationship),
  'position': instance.position,
  'moderationStatus': _moderationStatusToJson(instance.moderationStatus),
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
