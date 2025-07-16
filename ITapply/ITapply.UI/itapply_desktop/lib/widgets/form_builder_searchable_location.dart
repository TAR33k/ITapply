import 'package:flutter/material.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:itapply_desktop/models/location.dart';

class FormBuilderSearchableLocation extends StatelessWidget {
  final String name;
  final List<Location> locations;
  final String labelText;
  final String? Function(Location?)? validator;

  const FormBuilderSearchableLocation({
    super.key,
    required this.name,
    required this.locations,
    this.labelText = "Job Location",
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTypeAhead<Location?>(
      name: name,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
      itemBuilder: (context, location) {
        return ListTile(
          title: Text("${location?.city ?? ''}, ${location?.country ?? ''}"),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return locations;
        return locations
            .where((loc) =>
                loc.city.toLowerCase().contains(pattern.toLowerCase()) ||
                loc.country.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      selectionToTextTransformer: (location) =>
          location != null ? "${location.city}, ${location.country}" : "",
      valueTransformer: (location) => location?.id,
    );
  }
}
