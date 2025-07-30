import 'package:itapply_mobile/models/preferences.dart';
import 'package:itapply_mobile/models/requests/preferences_insert_request.dart';
import 'package:itapply_mobile/models/requests/preferences_update_request.dart';
import 'package:itapply_mobile/models/search_objects/preferences_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class PreferencesProvider extends BaseProvider<Preferences, PreferencesSearchObject, PreferencesInsertRequest, PreferencesUpdateRequest> {
  PreferencesProvider() : super("Preferences");

  @override
  Preferences fromJson(data) {
    return Preferences.fromJson(data);
  }
}
