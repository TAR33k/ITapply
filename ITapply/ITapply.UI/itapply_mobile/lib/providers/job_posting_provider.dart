import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/requests/job_posting_insert_request.dart';
import 'package:itapply_mobile/models/requests/job_posting_update_request.dart';
import 'package:itapply_mobile/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class JobPostingProvider extends BaseProvider<JobPosting, JobPostingSearchObject, JobPostingInsertRequest, JobPostingUpdateRequest> {
  JobPostingProvider() : super("JobPosting");

  @override
  JobPosting fromJson(data) {
    return JobPosting.fromJson(data);
  }

  Future<JobPosting> updateStatus(int id, JobPostingStatus status) async {
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

  Future<List<JobPosting>> getRecommended(int candidateId) async {
    var url = "$baseUrl$endpoint/recommended/$candidateId";
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
}
