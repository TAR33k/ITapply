import 'package:json_annotation/json_annotation.dart';

part 'base_search_object.g.dart';

@JsonSerializable()
class BaseSearchObject implements ISearchObject {
  int? Page;
  int? PageSize;
  bool? IncludeTotalCount;
  bool? RetrieveAll;

  BaseSearchObject({
    this.Page = 0,
    this.PageSize = 10,
    this.IncludeTotalCount = false,
    this.RetrieveAll = false,
  });

  @override
  Map<String, dynamic> toJson() => _$BaseSearchObjectToJson(this);
}

abstract class ISearchObject {
  Map<String, dynamic> toJson();
}
