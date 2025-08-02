import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/skill.dart';

class FormBuilderChips extends FormBuilderField<List<Skill>> {
  final List<Skill> allSkills;
  final String? searchHint;
  final bool showSearchField;

  // ignore: use_super_parameters
  FormBuilderChips({
    super.key,
    required super.name,
    required this.allSkills,
    List<Skill>? initialValue,
    FormFieldValidator<List<Skill>>? validator,
    ValueChanged<List<Skill>?>? onChanged,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    this.searchHint = 'Search skills...',
    this.showSearchField = true,
  }) : super(
          initialValue: initialValue ?? [],
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<List<Skill>> field) {
            final state = field as _FormBuilderChipsState;
            return state._buildChipsWidget();
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
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildChipsWidget() {
    final filtered = _query.isEmpty
        ? []
        : widget.allSkills
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) &&
                !(value?.contains(s) ?? false))
            .take(10)
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (widget.showSearchField)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                setState(() {
                  _query = val;
                  _showSuggestions = val.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _showSuggestions = _query.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (_showSuggestions && filtered.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final skill = filtered[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    skill.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    final updated = [...value ?? [], skill];
                    _controller.clear();
                    setState(() {
                      _query = '';
                      _showSuggestions = false;
                    });
                    didChange(updated.cast<Skill>());
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        if ((value?.isNotEmpty ?? false))
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: value!.map((skill) {
              return Chip(
                label: Text(
                  skill.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: AppTheme.primaryColor,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                onDeleted: () {
                  final updated = value!.where((s) => s.id != skill.id).toList();
                  didChange(updated.cast<Skill>());
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        if (_showSuggestions)
          GestureDetector(
            onTap: () {
              setState(() {
                _showSuggestions = false;
              });
            },
            child: Container(
              height: 50,
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}