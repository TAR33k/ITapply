import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/requests/candidate_insert_request.dart';
import 'package:itapply_desktop/models/requests/candidate_update_request.dart';
import 'package:itapply_desktop/models/search_objects/candidate_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class CandidateProvider extends BaseProvider<Candidate, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest> {
  CandidateProvider() : super("Candidate");

  @override
  Candidate fromJson(data) {
    return Candidate.fromJson(data);
  }
}