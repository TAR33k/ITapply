import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/requests/candidate_insert_request.dart';
import 'package:itapply_mobile/models/requests/candidate_update_request.dart';
import 'package:itapply_mobile/models/search_objects/candidate_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class CandidateProvider extends BaseProvider<Candidate, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest> {
  CandidateProvider() : super("Candidate");

  @override
  Candidate fromJson(data) {
    return Candidate.fromJson(data);
  }
}
