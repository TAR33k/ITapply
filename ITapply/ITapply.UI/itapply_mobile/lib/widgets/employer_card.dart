import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/employer_skill.dart';

class EmployerCard extends StatelessWidget {
  final Employer employer;
  final List<EmployerSkill> skills;
  final double averageRating;
  final int reviewCount;
  final int activeJobCount;
  final bool isGuest;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsPressed;

  const EmployerCard({
    super.key,
    required this.employer,
    required this.skills,
    required this.averageRating,
    required this.reviewCount,
    required this.activeJobCount,
    this.isGuest = false,
    this.onTap,
    this.onDetailsPressed,
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
              _buildHeader(),
              const SizedBox(height: 12),
              _buildCompanyMeta(),
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

  Widget _buildHeader() {
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
                employer.companyName,
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
                employer.industry ?? 'Unknown Industry',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyLogo() {
    if (employer.logo != null && employer.logo!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(employer.logo!);
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.grayColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackLogo();
              },
            ),
          ),
        );
      } catch (e) {
        return _buildFallbackLogo();
      }
    }
    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    final initials = _getCompanyInitials(employer.companyName);
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

  Widget _buildCompanyMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaItem(Icons.location_on_outlined, employer.locationName ?? 'Unknown Location'),
        const SizedBox(height: 4),
        _buildRatingRow(),
        const SizedBox(height: 4),
        _buildMetaItem(Icons.business_outlined, _buildCompanySizeText()),
        const SizedBox(height: 4),
        _buildMetaItem(Icons.work_outline, '$activeJobCount active job${activeJobCount != 1 ? 's' : ''}'),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(width: 8),
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

  Widget _buildRatingRow() {
    if (reviewCount == 0) {
      return _buildMetaItem(Icons.star_outline, 'No reviews yet');
    }
    
    return Wrap(
      children: [
        Icon(
          Icons.star_outline,
          size: 16,
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(width: 8),
        _buildStarRating(),
        const SizedBox(width: 8),
        Text(
          '${averageRating.toStringAsFixed(1)} ($reviewCount review${reviewCount != 1 ? 's' : ''})',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < averageRating.floor()) {
          return const Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          );
        } else if (index < averageRating) {
          return const Icon(
            Icons.star_half,
            size: 16,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: 16,
            color: Colors.grey.shade400,
          );
        }
      }),
    );
  }

  String _buildCompanySizeText() {
    final size = employer.size;
    if (size == null || size.isEmpty) {
      return 'Company size not specified';
    }
    return size;
  }

  Widget _buildSkillTags() {
    const maxVisibleSkills = 5;
    final visibleSkills = skills.take(maxVisibleSkills).toList();
    final remainingCount = skills.length - maxVisibleSkills;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...visibleSkills.map((skill) => _buildSkillChip(skill.skillName ?? 'Unknown')),
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

  Widget _buildSkillChip(String skillName) {
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
        skillName,
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
        if (isGuest)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Login to view',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onDetailsPressed ?? onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
