import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/location_insert_request.dart';
import 'package:itapply_desktop/models/requests/location_update_request.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class LocationProvider extends BaseProvider<Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest> {
  LocationProvider() : super("Location");

  @override
  Location fromJson(data) {
    return Location.fromJson(data);
  }
}