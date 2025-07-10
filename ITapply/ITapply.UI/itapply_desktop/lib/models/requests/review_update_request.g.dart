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
  ReviewRelationship.currentEmployee: 0,
  ReviewRelationship.formerEmployee: 1,
  ReviewRelationship.interviewee: 2,
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 0,
  ModerationStatus.approved: 1,
  ModerationStatus.rejected: 2,
};
