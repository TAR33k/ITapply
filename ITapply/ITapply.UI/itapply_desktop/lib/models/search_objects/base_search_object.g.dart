// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
BaseSearchObject _$BaseSearchObjectFromJson(Map<String, dynamic> json) =>
    BaseSearchObject(
      Page: (json['Page'] as num?)?.toInt() ?? 0,
      PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
      IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
      RetrieveAll: json['RetrieveAll'] as bool? ?? false,
    );

Map<String, dynamic> _$BaseSearchObjectToJson(BaseSearchObject instance) =>
    <String, dynamic>{
      'Page': instance.Page,
      'PageSize': instance.PageSize,
      'IncludeTotalCount': instance.IncludeTotalCount,
      'RetrieveAll': instance.RetrieveAll,
    };
