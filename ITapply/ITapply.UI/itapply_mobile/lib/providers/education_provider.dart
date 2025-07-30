import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/education.dart';
import 'package:itapply_desktop/models/requests/education_insert_request.dart';
import 'package:itapply_desktop/models/requests/education_update_request.dart';
import 'package:itapply_desktop/models/search_objects/education_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class EducationProvider extends BaseProvider<Education, EducationSearchObject, EducationInsertRequest, EducationUpdateRequest> {
  EducationProvider() : super("Education");

  @override
  Education fromJson(data) {
    return Education.fromJson(data);
  }

  Future<List<Education>> getByCandidateId(int candidateId) async {
    var url = "$baseUrl$endpoint/candidate/$candidateId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return (data as List).map((e) => fromJson(e)).toList();
    } else {
      throw Exception("Unkown error");
    }
  }

  Future<String> getHighestDegree(int candidateId) async {
    var url = "$baseUrl$endpoint/candidate/$candidateId/highest-degree";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return response.body;
    } else {
      throw Exception("Unknown error");
    }
  }
}