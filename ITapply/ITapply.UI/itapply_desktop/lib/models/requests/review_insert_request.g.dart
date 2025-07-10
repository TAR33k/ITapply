// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewInsertRequest _$ReviewInsertRequestFromJson(Map<String, dynamic> json) =>
    ReviewInsertRequest(
      candidateId: (json['candidateId'] as num).toInt(),
      employerId: (json['employerId'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      relationship: $enumDecode(
        _$ReviewRelationshipEnumMap,
        json['relationship'],
      ),
      position: json['position'] as String,
    );

Map<String, dynamic> _$ReviewInsertRequestToJson(
  ReviewInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'employerId': instance.employerId,
  'rating': instance.rating,
  'comment': instance.comment,
  'relationship': _reviewRelationshipToJson(instance.relationship),
  'position': instance.position,
};

const _$ReviewRelationshipEnumMap = {
  ReviewRelationship.currentEmployee: 'currentEmployee',
  ReviewRelationship.formerEmployee: 'formerEmployee',
  ReviewRelationship.interviewee: 'interviewee',
};
