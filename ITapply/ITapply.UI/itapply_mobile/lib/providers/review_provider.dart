import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/requests/review_insert_request.dart';
import 'package:itapply_mobile/models/requests/review_update_request.dart';
import 'package:itapply_mobile/models/review.dart';
import 'package:itapply_mobile/models/search_objects/review_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review, 
    ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  Future<Review> updateModerationStatus(int id, ModerationStatus status) async {
    var url = "$baseUrl$endpoint/$id/moderation/${status.index}";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to update moderation status");
    }
  }

  Future<List<Review>> getByEmployerId(int employerId) async {
    var url = "$baseUrl$endpoint/employer/$employerId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return (data as List).map((e) => fromJson(e)).toList();
    } else {
      throw Exception("Failed to get reviews by employer id");
    }
  }

  Future<double> getAverageRatingForEmployer(int employerId) async {
    var url = "$baseUrl$endpoint/employer/$employerId/rating";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data as double;
    } else {
      throw Exception("Failed to get average rating for employer");
    }
  }
}
