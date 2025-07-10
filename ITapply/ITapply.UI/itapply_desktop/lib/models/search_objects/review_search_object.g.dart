// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewSearchObject _$ReviewSearchObjectFromJson(Map<String, dynamic> json) =>
    ReviewSearchObject(
      CandidateId: (json['CandidateId'] as num?)?.toInt(),
      EmployerId: (json['EmployerId'] as num?)?.toInt(),
      CandidateName: json['CandidateName'] as String?,
      CompanyName: json['CompanyName'] as String?,
      MinRating: (json['MinRating'] as num?)?.toInt(),
      MaxRating: (json['MaxRating'] as num?)?.toInt(),
      relationship: $enumDecodeNullable(
        _$ReviewRelationshipEnumMap,
        json['Relationship'],
      ),
      moderationStatus: $enumDecodeNullable(
        _$ModerationStatusEnumMap,
        json['ModerationStatus'],
      ),
      ReviewDateFrom: json['ReviewDateFrom'] == null
          ? null
          : DateTime.parse(json['ReviewDateFrom'] as String),
      ReviewDateTo: json['ReviewDateTo'] == null
          ? null
          : DateTime.parse(json['ReviewDateTo'] as String),
      Page: (json['Page'] as num?)?.toInt() ?? 0,
      PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
      IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
      RetrieveAll: json['RetrieveAll'] as bool? ?? false,
    );

Map<String, dynamic> _$ReviewSearchObjectToJson(ReviewSearchObject instance) =>
    <String, dynamic>{
      'Page': instance.Page,
      'PageSize': instance.PageSize,
      'IncludeTotalCount': instance.IncludeTotalCount,
      'RetrieveAll': instance.RetrieveAll,
      'CandidateId': instance.CandidateId,
      'EmployerId': instance.EmployerId,
      'CandidateName': instance.CandidateName,
      'CompanyName': instance.CompanyName,
      'MinRating': instance.MinRating,
      'MaxRating': instance.MaxRating,
      'Relationship': _reviewRelationshipToJson(instance.relationship),
      'ModerationStatus': _moderationStatusToJson(instance.moderationStatus),
      'ReviewDateFrom': instance.ReviewDateFrom?.toIso8601String(),
      'ReviewDateTo': instance.ReviewDateTo?.toIso8601String(),
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
