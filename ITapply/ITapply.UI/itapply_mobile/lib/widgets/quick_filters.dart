import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_theme.dart';

class QuickFilters extends StatelessWidget {
  final String title;
  final List<String> filters;
  final List<String> selectedFilters;
  final Function(String) onFilterTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const QuickFilters({
    super.key,
    required this.title,
    required this.filters,
    required this.selectedFilters,
    required this.onFilterTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isSelected = selectedFilters.contains(filter);
              return _buildFilterChip(filter, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, bool isSelected) {
    return GestureDetector(
      onTap: () => onFilterTap(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.lightColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grayColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textColor,
          ),
        ),
      ),
    );
  }
}

class HomeQuickFilters extends StatelessWidget {
  final List<String> selectedFilters;
  final Function(String) onFilterTap;

  const HomeQuickFilters({
    super.key,
    required this.selectedFilters,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final quickFilters = [
      'Full Stack',
      'Frontend',
      'Backend',
      'DevOps',
      'Mobile',
      'QA',
    ];

    return QuickFilters(
      title: 'Quick Filters',
      filters: quickFilters,
      selectedFilters: selectedFilters,
      onFilterTap: onFilterTap,
    );
  }
}
