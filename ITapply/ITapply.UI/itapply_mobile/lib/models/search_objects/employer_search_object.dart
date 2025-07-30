import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employer_search_object.g.dart';

@JsonSerializable()
class EmployerSearchObject extends BaseSearchObject {
  String? CompanyName;
  String? Industry;
  int? MinYearsInBusiness;
  int? MaxYearsInBusiness;
  int? LocationId;
  String? ContactEmail;
  @JsonKey(name: 'VerificationStatus',toJson: _verificationStatusToJson)
  VerificationStatus? verificationStatus;
  String? Email;
  bool? IsActive;

  EmployerSearchObject({
    this.CompanyName,
    this.Industry,
    this.MinYearsInBusiness,
    this.MaxYearsInBusiness,
    this.LocationId,
    this.ContactEmail,
    this.verificationStatus,
    this.Email,
    this.IsActive,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$EmployerSearchObjectToJson(this);
}

int? _verificationStatusToJson(VerificationStatus? status) => status?.index;
