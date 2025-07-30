import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/requests/review_insert_request.dart';
import 'package:itapply_desktop/models/requests/review_update_request.dart';
import 'package:itapply_desktop/models/review.dart';
import 'package:itapply_desktop/models/search_objects/review_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

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
}