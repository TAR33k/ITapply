import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/providers/auth_provider.dart';

class JobPostingProvider {
  static String? _baseUrl;
  JobPostingProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:8080",
    );
  }

  Future<dynamic> get() async {
    var url = "$_baseUrl/JobPosting";
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Something went wrong, please try again later");
    }
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode <= 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Something went wrong, please try again later");
    }
  }

  Map<String, String> createHeaders() {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode("${AuthProvider.email}:${AuthProvider.password}"))}';
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    return headers;
  }
}
