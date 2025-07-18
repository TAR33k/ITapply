import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/models/skill.dart';

class FormBuilderChips extends FormBuilderField<List<Skill>> {
  final List<Skill> allSkills;

  FormBuilderChips({
    super.key,
    required super.name,
    required this.allSkills,
    List<Skill> initialSkills = const [],
    FormFieldValidator<List<Skill>>? validator,
    ValueChanged<List<Skill>?>? onChanged,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          initialValue: initialSkills,
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          builder: (field) {
            return const SizedBox.shrink();
          },
        );

  @override
  FormBuilderFieldState<FormBuilderChips, List<Skill>> createState() =>
      _FormBuilderChipsState();
}

class _FormBuilderChipsState
    extends FormBuilderFieldState<FormBuilderChips, List<Skill>> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? []
        : widget.allSkills
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) &&
                !(value?.contains(s) ?? false))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(errorText!, style: const TextStyle(color: Colors.red)),
          ),
        TextField(
          controller: _controller,
          onChanged: (val) {
            setState(() => _query = val);
          },
          decoration: const InputDecoration(
            labelText: 'Search Skills',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: filtered.map((skill) {
              return ActionChip(
                label: Text(skill.name, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                shape: const StadiumBorder(side: BorderSide.none),
                side: BorderSide(color: AppTheme.primaryColor),
                onPressed: () {
                  final updated = [...value ?? [], skill];
                  _controller.clear();
                  setState(() => _query = '');
                  didChange(updated.cast<Skill>());
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        if ((value?.isNotEmpty ?? false))
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: value!.map((skill) {
              return InputChip(
                label: Text(skill.name, style: TextStyle(color: AppTheme.lightColor, fontWeight: FontWeight.bold)),
                shape: const StadiumBorder(side: BorderSide.none),
                side: BorderSide(color: AppTheme.primaryColor),
                backgroundColor: AppTheme.primaryColor,
                deleteIconColor: AppTheme.lightColor,
                onDeleted: () {
                  final updated = List<Skill>.from(value!);
                  updated.remove(skill);
                  didChange(updated);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
