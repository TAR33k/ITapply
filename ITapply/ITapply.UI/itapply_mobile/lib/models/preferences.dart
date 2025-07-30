import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';
@JsonSerializable(explicitToJson: true)
class Preferences {
  final int id;
  final int candidateId;
  final int? locationId;
  final String? locationName;
  @JsonKey(unknownEnumValue: EmploymentType.fullTime)
  final EmploymentType? employmentType;
  @JsonKey(unknownEnumValue: Remote.no)
  final Remote? remote;

  Preferences({
    required this.id,
    required this.candidateId,
    this.locationId,
    this.locationName,
    this.employmentType,
    this.remote,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
