// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
LocationSearchObject _$LocationSearchObjectFromJson(
  Map<String, dynamic> json,
) => LocationSearchObject(
  City: json['City'] as String?,
  Country: json['Country'] as String?,
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$LocationSearchObjectToJson(
  LocationSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'City': instance.City,
  'Country': instance.Country,
};
