import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/work_experience.dart';
import 'package:itapply_desktop/models/requests/work_experience_insert_request.dart';
import 'package:itapply_desktop/models/requests/work_experience_update_request.dart';
import 'package:itapply_desktop/models/search_objects/work_experience_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class WorkExperienceProvider extends BaseProvider<WorkExperience, WorkExperienceSearchObject, WorkExperienceInsertRequest, WorkExperienceUpdateRequest> {
  WorkExperienceProvider() : super("WorkExperience");

  @override
  WorkExperience fromJson(data) {
    return WorkExperience.fromJson(data);
  }

  Future<List<WorkExperience>> getByCandidateId(int candidateId) async {
    var url = "$baseUrl$endpoint/candidate/$candidateId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return (data as List).map((e) => fromJson(e)).toList();
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<int> getTotalExperienceMonths(int candidateId) async {
    var url = "$baseUrl$endpoint/candidate/$candidateId/total-months";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception("Unknown error");
    }
  }
}