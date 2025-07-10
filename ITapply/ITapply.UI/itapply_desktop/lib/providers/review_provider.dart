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
}