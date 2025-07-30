import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/requests/employer_insert_request.dart';
import 'package:itapply_desktop/models/requests/employer_update_request.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class EmployerProvider extends BaseProvider<Employer, EmployerSearchObject, EmployerInsertRequest, EmployerUpdateRequest> {
  EmployerProvider() : super("Employer");

  @override
  Employer fromJson(data) {
    return Employer.fromJson(data);
  }

  Future<Employer> updateVerificationStatus(int id, VerificationStatus status) async {
    var url = "$baseUrl$endpoint/$id/verification-status?status=${status.index}";
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
}