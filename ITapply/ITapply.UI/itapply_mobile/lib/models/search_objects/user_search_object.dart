import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_search_object.g.dart';

@JsonSerializable()
class UserSearchObject extends BaseSearchObject {
  String? Email;
  DateTime? RegistrationDate;
  bool? IsActive;

  UserSearchObject({
    this.Email,
    this.RegistrationDate,
    this.IsActive,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$UserSearchObjectToJson(this);
}