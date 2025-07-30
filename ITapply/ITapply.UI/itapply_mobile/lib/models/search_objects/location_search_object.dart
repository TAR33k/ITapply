import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_search_object.g.dart';

@JsonSerializable()
class LocationSearchObject extends BaseSearchObject {
  String? City;
  String? Country;

  LocationSearchObject({
    this.City,
    this.Country,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$LocationSearchObjectToJson(this);
}