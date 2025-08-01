import 'package:flutter/material.dart';
import 'package:itapply_mobile/models/requests/candidate_insert_request.dart';
import 'package:itapply_mobile/models/requests/user_insert_request.dart';
import 'package:itapply_mobile/models/search_objects/role_search_object.dart';
import 'package:itapply_mobile/models/user.dart';
import 'package:itapply_mobile/providers/candidate_provider.dart';
import 'package:itapply_mobile/providers/role_provider.dart';
import 'package:itapply_mobile/providers/user_provider.dart';

class CandidateRegistrationProvider with ChangeNotifier {
  final UserProvider _userProvider;
  final CandidateProvider _candidateProvider;
  final RoleProvider _roleProvider;

  CandidateRegistrationProvider(this._userProvider, this._candidateProvider, this._roleProvider);

  Future<void> registerCandidate({
    required UserInsertRequest userRequest,
    required Map<String, dynamic> candidateData,
  }) async {
    User? newUser;
    try {
      newUser = await _userProvider.insert(userRequest);

      final candidateRequest = CandidateInsertRequest(
        userId: newUser.id,
        firstName: candidateData['firstName'],
        lastName: candidateData['lastName'],
        phoneNumber: candidateData['phoneNumber'],
        title: candidateData['title'],
        bio: candidateData['bio'],
        locationId: candidateData['locationId'],
        experienceYears: candidateData['experienceYears'],
        experienceLevel: candidateData['experienceLevel'],
      );
      await _candidateProvider.insert(candidateRequest);

    } catch (e) {
      if (newUser != null) {
        await _userProvider.delete(newUser.id);
      }
    }
  }

  Future<int> getCandidateRoleId() async {
    try {
      final data = await _roleProvider.get(filter: RoleSearchObject(Name: "Candidate"));
      if (data.items!.isNotEmpty) {
        return data.items!.first.id;
      } else {
        return 2;
      }
    } catch (e) {
      throw Exception("Could not fetch user roles.");
    }
  }
}
