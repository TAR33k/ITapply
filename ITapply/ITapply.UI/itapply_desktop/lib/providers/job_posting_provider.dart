import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/model/job_posting.dart';
import 'package:itapply_desktop/model/search_result.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';

class JobPostingProvider extends ChangeNotifier{
  static String? _baseUrl;
  JobPostingProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:8080",
    );
  }

  Future<SearchResult<JobPosting>> get(dynamic filter) async {
    var url = "$_baseUrl/JobPosting";

    if (filter != null) {
      var query = getQueryString(filter);
      if (query.isNotEmpty) {
        url += '?$query';
      }
    }

    var uri = Uri.parse(url);

    print("Fetching job postings from: $uri");

    var response = await http.get(uri, headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var searchResult = SearchResult<JobPosting>(
        totalCount: data['totalCount'],
        items: List<JobPosting>.from(data['items']
            .map((e) => JobPosting.fromJson(e)))
      );

      return searchResult;
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

  String getQueryString(Map params,
    {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
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
