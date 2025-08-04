import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:provider/provider.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/employer_skill.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/review.dart';
import 'package:itapply_mobile/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_mobile/models/search_objects/employer_skill_search_object.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/employer_skill_provider.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/providers/review_provider.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/widgets/job_card.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/providers/utils.dart';

class EmployerDetailsScreen extends StatefulWidget {
  final int employerId;
  final bool isGuest;

  const EmployerDetailsScreen({
    super.key,
    required this.employerId,
    this.isGuest = false,
  });

  @override
  State<EmployerDetailsScreen> createState() => _EmployerDetailsScreenState();
}

class _EmployerDetailsScreenState extends State<EmployerDetailsScreen> {
  Employer? _employer;
  List<EmployerSkill> _skills = [];
  List<JobPosting> _jobPostings = [];
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoading = true;
  String? _error;
  String _jobSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadEmployerData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employerProvider = Provider.of<EmployerProvider>(context, listen: false);
      final skillProvider = Provider.of<EmployerSkillProvider>(context, listen: false);
      final jobProvider = Provider.of<JobPostingProvider>(context, listen: false);
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

      _employer = await employerProvider.getById(widget.employerId);

      final skillsResult = await skillProvider.get(
        filter: EmployerSkillSearchObject(EmployerId: widget.employerId, RetrieveAll: true),
      );
      _skills = skillsResult.items ?? [];

      final jobsResult = await jobProvider.get(
        filter: JobPostingSearchObject(
          EmployerId: widget.employerId,
          Status: JobPostingStatus.active,
          RetrieveAll: true,
        ),
      );
      _jobPostings = jobsResult.items ?? [];

      try {
        final allReviews = await reviewProvider.getByEmployerId(widget.employerId);
        _reviews = allReviews.where((review) => review.moderationStatus == ModerationStatus.approved).toList();
        _reviewCount = _reviews.length;
        
        if (_reviewCount > 0) {
          try {
            _averageRating = await reviewProvider.getAverageRatingForEmployer(widget.employerId);
          } catch (e) {
            if (_reviews.isNotEmpty) {
              _averageRating = _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
            } else {
              _averageRating = 0.0;
            }
          }
        } else {
          _averageRating = 0.0;
        }
      } catch (e) {
        _reviews = [];
        _averageRating = 0.0;
        _reviewCount = 0;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<JobPosting> get _filteredJobPostings {
    if (_jobSearchQuery.isEmpty) return _jobPostings;
    
    return _jobPostings.where((job) {
      return job.title.toLowerCase().contains(_jobSearchQuery.toLowerCase()) ||
             job.description.toLowerCase().contains(_jobSearchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pop(_dataChanged ? true : null);
        }
      },
      child: MasterScreen(
        showBackButton: true,
        selectedIndex: 2,
        title: 'Employer Details',
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load employer details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEmployerData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_employer == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployerHeader(),
          const SizedBox(height: 20),
          _buildEmployerInfo(),
          const SizedBox(height: 20),
          if (_employer!.benefits != null) ...[
            _buildBenefitsSection(),
            const SizedBox(height: 20),
          ],
          _buildSkillsSection(),
          const SizedBox(height: 20),
          _buildJobPostingsSection(),
          const SizedBox(height: 20),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildEmployerHeader() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCompanyLogo(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _employer!.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (_employer!.industry != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _employer!.industry!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            _buildRatingRow(),
            if (_employer!.description != null) ...[
              const SizedBox(height: 16),
              Text(
                _employer!.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    if (_employer!.logo != null && _employer!.logo!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(_employer!.logo!);
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.grayColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
    final initials = _getCompanyInitials(_employer!.companyName);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getCompanyInitials(String companyName) {
    final words = companyName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CO';
  }

  Widget _buildRatingRow() {
    if (_reviewCount == 0) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Icon(
            Icons.star_outline,
            size: 20,
            color: AppTheme.secondaryColor,
          ),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        _buildStarRating(),
        Text(
          '${_averageRating.toStringAsFixed(1)} ($_reviewCount review${_reviewCount != 1 ? 's' : ''})',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < _averageRating.floor()) {
          return const Icon(
            Icons.star,
            size: 20,
            color: Colors.amber,
          );
        } else if (index < _averageRating) {
          return const Icon(
            Icons.star_half,
            size: 20,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: 20,
            color: Colors.grey.shade400,
          );
        }
      }),
    );
  }

  Widget _buildEmployerInfo() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_city, 'Location', _employer!.locationName ?? 'Not specified'),
            _buildInfoRow(Icons.business, 'Company Size', _employer!.size ?? 'Not specified'),
            if (_employer!.website != null)
              _buildInfoRow(Icons.language, 'Website', _employer!.website!),
            if (_employer!.address != null)
              _buildInfoRow(Icons.location_on, 'Address', _employer!.address!),
            if (_employer!.contactPhone != null)
              _buildInfoRow(Icons.phone, 'Contact Phone', _employer!.contactPhone!),
            if (_employer!.contactEmail != null)
              _buildInfoRow(Icons.email, 'Contact Email', _employer!.contactEmail!),
            if (_employer!.yearsInBusiness != null)
              _buildInfoRow(Icons.calendar_today, 'Years in Business', '${_employer!.yearsInBusiness} years'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(_employer!.benefits ?? 'No benefits available'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    if (_skills.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technologies & Skills',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) => _buildSkillChip(skill.skillName ?? 'Unknown')).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skillName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 1,
        ),
      ),
      child: Text(
        skillName,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.lightColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildJobPostingsSection() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Active Job Postings (${_filteredJobPostings.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search job postings...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _jobSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _jobSearchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _jobSearchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_filteredJobPostings.isEmpty)
              _buildEmptyJobsState()
            else
              ..._filteredJobPostings.map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(
                  jobId: job.id,
                  jobTitle: job.title,
                  companyName: job.employerName,
                  companyLogoBase64: _employer!.logo,
                  location: "${job.locationName ?? 'Remote'} (${remoteToString(job.remote)})",
                  employmentType: job.employmentType,
                  postedDate: job.postedDate,
                  deadlineDate: job.applicationDeadline,
                  skills: job.skills.map((s) => s.skillName ?? 'Unknown Skill').toList(),
                  isGuest: widget.isGuest,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.jobDetailsRoute,
                      arguments: {'jobId': job.id, 'selectedIndex': 2},
                    );
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyJobsState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.work_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _jobSearchQuery.isEmpty 
                ? 'No active job postings'
                : 'No job postings match your search',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_jobSearchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Text(
                  'Reviews: $_reviewCount',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 50),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.employerReviewsRoute,
                      arguments: {
                        'employerId': widget.employerId,
                        'companyName': _employer!.companyName,
                        'isGuest': widget.isGuest,
                      },
                    );
                    
                    if (result == true) {
                      _dataChanged = true;
                      _loadEmployerData();
                    }
                  },
                  child: const Text('View Reviews', style: TextStyle(color: AppTheme.lightColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
