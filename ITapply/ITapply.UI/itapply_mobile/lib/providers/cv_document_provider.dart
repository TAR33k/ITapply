import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/cv_document.dart';
import 'package:itapply_desktop/models/requests/cv_document_insert_request.dart';
import 'package:itapply_desktop/models/requests/cv_document_update_request.dart';
import 'package:itapply_desktop/models/search_objects/cv_document_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class CVDocumentProvider extends BaseProvider<CVDocument, CVDocumentSearchObject, CVDocumentInsertRequest, CVDocumentUpdateRequest> {
  CVDocumentProvider() : super("CVDocument");

  @override
  CVDocument fromJson(data) {
    return CVDocument.fromJson(data);
  }

  Future<CVDocument> setAsMain(int id) async {
    var url = "$baseUrl$endpoint/$id/main";
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

  Future<List<CVDocument>> getByCandidateId(int candidateId) async {
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
}