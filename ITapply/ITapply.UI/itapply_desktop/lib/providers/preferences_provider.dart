import 'package:itapply_desktop/models/preferences.dart';
import 'package:itapply_desktop/models/requests/preferences_insert_request.dart';
import 'package:itapply_desktop/models/requests/preferences_update_request.dart';
import 'package:itapply_desktop/models/search_objects/preferences_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class PreferencesProvider extends BaseProvider<Preferences, PreferencesSearchObject, PreferencesInsertRequest, PreferencesUpdateRequest> {
  PreferencesProvider() : super("Preferences");

  @override
  Preferences fromJson(data) {
    return Preferences.fromJson(data);
  }
}