import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_mobile/models/application.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/requests/application_insert_request.dart';
import 'package:itapply_mobile/models/requests/application_update_request.dart';
import 'package:itapply_mobile/models/search_objects/application_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class ApplicationProvider extends BaseProvider<Application, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest> {
  ApplicationProvider() : super("Application");

  @override
  Application fromJson(data) {
    return Application.fromJson(data);
  }

  Future<Application> updateStatus(int id, ApplicationStatus status) async {
    var url = "$baseUrl$endpoint/$id/status?status=${status.index}";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      notifyListeners();
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<bool> hasApplied(int candidateId, int jobPostingId) async {
    var url = "$baseUrl$endpoint/check?candidateId=$candidateId&jobPostingId=$jobPostingId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception("Unknown error");
    }
  }
}
