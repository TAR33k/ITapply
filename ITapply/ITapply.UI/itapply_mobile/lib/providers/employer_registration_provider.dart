import 'package:flutter/material.dart';
import 'package:itapply_mobile/models/requests/employer_insert_request.dart';
import 'package:itapply_mobile/models/requests/user_insert_request.dart';
import 'package:itapply_mobile/models/search_objects/role_search_object.dart';
import 'package:itapply_mobile/models/user.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/role_provider.dart';
import 'package:itapply_mobile/providers/user_provider.dart';

class EmployerRegistrationProvider with ChangeNotifier {
  final UserProvider _userProvider;
  final EmployerProvider _employerProvider;
  final RoleProvider _roleProvider;

  EmployerRegistrationProvider(this._userProvider, this._employerProvider, this._roleProvider);

  Future<void> registerEmployer({
    required UserInsertRequest userRequest,
    required Map<String, dynamic> employerData,
  }) async {
    User? newUser;
    try {
      newUser = await _userProvider.insert(userRequest);

      final employerRequest = EmployerInsertRequest(
        userId: newUser.id,
        companyName: employerData['companyName'],
        industry: employerData['industry'],
        yearsInBusiness: int.parse(employerData['yearsInBusiness']),
        description: employerData['description'],
        benefits: employerData['benefits'],
        address: employerData['address'],
        size: employerData['size'],
        website: employerData['website'],
        contactEmail: employerData['contactEmail'],
        contactPhone: employerData['contactPhone'],
        locationId: employerData['locationId'],
        logo: employerData['logo'],
      );
      await _employerProvider.insert(employerRequest);

    } catch (e) {
      
      if (newUser != null) {
        await _userProvider.delete(newUser.id);
      }
    }
  }

  Future<int> getEmployerRoleId() async {
    try {
      final data = await _roleProvider.get(filter: RoleSearchObject(Name: "Employer"));
      if (data.items!.isNotEmpty) {
        return data.items!.first.id;
      } else {
        return 3;
      }
    } catch (e) {
      throw Exception("Could not fetch user roles.");
    }
  }
}
