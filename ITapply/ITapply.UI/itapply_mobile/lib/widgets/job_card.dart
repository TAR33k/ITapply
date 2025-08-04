import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/providers/utils.dart';

class JobCard extends StatelessWidget {
  final int jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogoBase64;
  final String location;
  final EmploymentType employmentType;
  final DateTime postedDate;
  final DateTime? deadlineDate;
  final List<String> skills;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsPressed;
  final bool isGuest;

  const JobCard({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoBase64,
    required this.location,
    required this.employmentType,
    required this.postedDate,
    this.deadlineDate,
    required this.skills,
    this.onTap,
    this.onDetailsPressed,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.secondaryColor.withOpacity(0.02),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.grayColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobHeader(),
              const SizedBox(height: 12),
              _buildJobMeta(),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSkillTags(),
              ],
              const SizedBox(height: 12),
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompanyLogo(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                companyName,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyLogo() {
    if (companyLogoBase64 != null && companyLogoBase64!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(companyLogoBase64!);
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.grayColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitialsLogo(),
            ),
          ),
        );
      } catch (e) {
        return _buildInitialsLogo();
      }
    }
    return _buildInitialsLogo();
  }

  Widget _buildInitialsLogo() {
    final initials = _getCompanyInitials(companyName);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getCompanyInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  Widget _buildJobMeta() {
    final now = DateTime.now();
    final difference = now.difference(postedDate);
    String timeAgo;
    
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgo = 'Just now';
    }

    return Column(
      children: [
        _buildMetaItem(Icons.location_on_outlined, location),
        const SizedBox(height: 4),
        _buildMetaItem(Icons.work_outline, employmentTypeToString(employmentType)),
        const SizedBox(height: 4),
        _buildMetaItem(Icons.access_time, timeAgo),
        if (deadlineDate != null) ...[
          const SizedBox(height: 4),
          _buildMetaItem(
            Icons.event_outlined, 
            'Deadline: ${DateFormat('MMM dd, yyyy').format(deadlineDate!)}',
            color: _isDeadlineNear() ? AppTheme.accentColor : null,
          ),
        ],
      ],
    );
  }

  bool _isDeadlineNear() {
    if (deadlineDate == null) return false;
    final now = DateTime.now();
    final difference = deadlineDate!.difference(now);
    return difference.inDays <= 7;
  }

  Widget _buildMetaItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? AppTheme.secondaryColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppTheme.secondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillTags() {
    const maxVisibleSkills = 5;
    final visibleSkills = skills.take(maxVisibleSkills).toList();
    final remainingCount = skills.length - maxVisibleSkills;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...visibleSkills.map((skill) => _buildSkillChip(skill)),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount more',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.lightColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: onDetailsPressed ?? onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 1,
          ),
          child: const Text(
            'Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
