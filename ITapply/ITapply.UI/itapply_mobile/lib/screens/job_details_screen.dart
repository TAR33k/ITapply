import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/cv_document.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/cv_document_provider.dart';
import 'package:itapply_mobile/providers/application_provider.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/screens/apply_dialog.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  final int selectedIndex;

  const JobDetailsScreen({
    super.key,
    required this.jobId,
    required this.selectedIndex,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  JobPosting? _jobPosting;
  Employer? _employer;
  Candidate? _currentCandidate;
  List<CVDocument> _cvDocuments = [];
  bool _isLoading = true;
  bool _hasApplied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobPostingProvider = Provider.of<JobPostingProvider>(context, listen: false);
      final employerProvider = Provider.of<EmployerProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final jobResult = await jobPostingProvider.getById(widget.jobId);
      _jobPosting = jobResult;

      if (_jobPosting != null) {
        final employerResult = await employerProvider.getById(_jobPosting!.employerId);
        _employer = employerResult;
      }

      if (authProvider.currentUser != null) {
        try {
          final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);
          
          _currentCandidate = authProvider.currentCandidate;

          if (_currentCandidate != null) {
            _hasApplied = await applicationProvider.hasApplied(_currentCandidate!.id, widget.jobId);
            
            final cvProvider = Provider.of<CVDocumentProvider>(context, listen: false);
            _cvDocuments = await cvProvider.getByCandidateId(_currentCandidate!.id);
          }
        } catch (e) {
          debugPrint('Error loading candidate data: $e');
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showApplyDialog() async {
    if (_cvDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to upload a CV before applying for jobs. Go to your profile to upload a CV.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool? appliedSuccessfully = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ApplyDialog(
        jobPosting: _jobPosting!,
        candidate: _currentCandidate!,
        cvDocuments: _cvDocuments,
      ),
    );

    if (appliedSuccessfully == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuest = authProvider.currentUser == null;

    return MasterScreen(
      title: 'Job Details',
      selectedIndex: widget.selectedIndex,
      showBackButton: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _jobPosting == null
                  ? _buildNotFoundState()
                  : _buildJobDetails(isGuest),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading job details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadJobDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Job not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This job posting may have been removed or is no longer available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails(bool isGuest) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 24),
          _buildEmployerInfo(),
          const SizedBox(height: 24),
          _buildJobDescription(),
          if (_jobPosting!.requirements?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildRequirements(),
          ],
          if (_jobPosting!.benefits?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildBenefits(),
          ],
          const SizedBox(height: 24),
          _buildSkills(),
          const SizedBox(height: 24),
          _buildJobInfo(),
          const SizedBox(height: 32),
          _buildApplyButton(isGuest),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _jobPosting!.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _jobPosting!.employerName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.work, employmentTypeToString(_jobPosting!.employmentType)),
                _buildInfoChip(Icons.trending_up, experienceLevelToString(_jobPosting!.experienceLevel)),
                if (_jobPosting!.locationName != null)
                  _buildInfoChip(Icons.location_on, _jobPosting!.locationName!),
                _buildInfoChip(
                  Icons.laptop,
                  switch (_jobPosting!.remote) {
                    Remote.yes => 'Remote',
                    Remote.hybrid => 'Hybrid',
                    Remote.no => 'On-site',
                  },
                ),
              ],
            ),
            if (_jobPosting!.minSalary != null || _jobPosting!.maxSalary != null) ...[
              const SizedBox(height: 12),
              Wrap(
                children: [
                  Text(
                    _buildSalaryRange(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerInfo() {
    if (_employer == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_employer!.logo?.isNotEmpty == true)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(_employer!.logo!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.primaryColor,
                            child: Center(
                              child: Text(
                                _employer!.companyName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        _employer!.companyName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _employer!.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_employer!.industry?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          _employer!.industry!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_employer!.locationName?.isNotEmpty == true)
              _buildEmployerInfoRow(Icons.location_on, 'Location', _employer!.locationName!),
            if (_employer!.size?.isNotEmpty == true)
              _buildEmployerInfoRow(Icons.business, 'Company Size', _employer!.size!),
            if (_employer!.contactEmail?.isNotEmpty == true)
              _buildEmployerInfoRow(Icons.email, 'Contact', _employer!.contactEmail!),
            if (_employer!.website?.isNotEmpty == true)
              _buildEmployerInfoRow(Icons.language, 'Website', _employer!.website!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryColor),
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

  Widget _buildJobInfo() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildJobInfoRow('Posted', DateFormat.yMMMd().format(_jobPosting!.postedDate)),
            _buildJobInfoRow('Application Deadline', DateFormat.yMMMd().format(_jobPosting!.applicationDeadline)),
            _buildJobInfoRow('Applications', '${_jobPosting!.applicationCount} received'),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _jobPosting!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _jobPosting!.requirements!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
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
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _jobPosting!.benefits!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkills() {
    if (_jobPosting!.skills.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Skills',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _jobPosting!.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Text(
                    skill.skillName ?? 'Unknown Skill',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(bool isGuest) {
    if (isGuest) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.loginRoute);
          },
          icon: const Icon(Icons.login),
          label: const Text('Login to Apply'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (_hasApplied) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Already Applied'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[600],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final isExpired = _jobPosting!.applicationDeadline.isBefore(now);

    if (isExpired) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.schedule),
          label: const Text('Application Deadline Passed'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[600],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showApplyDialog,
        icon: const Icon(Icons.send),
        label: const Text('Apply Now'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.lightColor),
          const SizedBox(width: 6),
          Text(
            label.length > 15 ? '${label.substring(0, 15)}...' : label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSalaryRange() {
    if (_jobPosting!.minSalary != null && _jobPosting!.maxSalary != null && _jobPosting!.minSalary != 0 && _jobPosting!.maxSalary != 0) {
      return '${_jobPosting!.minSalary!.toString()} KM - ${_jobPosting!.maxSalary!.toString()} KM';
    } else if (_jobPosting!.minSalary != null && _jobPosting!.minSalary != 0) {
      return 'From ${_jobPosting!.minSalary!.toString()} KM';
    } else if (_jobPosting!.maxSalary != null && _jobPosting!.maxSalary != 0) {
      return 'Up to ${_jobPosting!.maxSalary!.toString()} KM';
    }
    return 'Salary not specified';
  }
}
