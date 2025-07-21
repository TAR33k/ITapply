import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/candidate_skill.dart';
import 'package:itapply_desktop/models/cv_document.dart';
import 'package:itapply_desktop/models/education.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/preferences.dart';
import 'package:itapply_desktop/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/cv_document_search_object.dart';
import 'package:itapply_desktop/models/search_objects/education_search_object.dart';
import 'package:itapply_desktop/models/search_objects/preferences_search_object.dart';
import 'package:itapply_desktop/models/search_objects/work_experience_search_object.dart';
import 'package:itapply_desktop/models/work_experience.dart';
import 'package:itapply_desktop/providers/candidate_skill_provider.dart';
import 'package:itapply_desktop/providers/cv_document_provider.dart';
import 'package:itapply_desktop/providers/education_provider.dart';
import 'package:itapply_desktop/providers/preferences_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/providers/work_experience_provider.dart';
import 'package:itapply_desktop/widgets/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';

class AdminCandidateDetailsScreen extends StatefulWidget {
  final Candidate candidate;

  const AdminCandidateDetailsScreen({super.key, required this.candidate});

  @override
  State<AdminCandidateDetailsScreen> createState() => _AdminCandidateDetailsScreenState();
}

class _AdminCandidateDetailsScreenState extends State<AdminCandidateDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<CandidateSkill> _candidateSkills = [];
  List<CVDocument> _cvDocuments = [];
  List<Education> _education = [];
  List<WorkExperience> _workExperience = [];
  Preferences? _preferences;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchCandidateData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCandidateData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        context.read<CandidateSkillProvider>().get(filter: CandidateSkillSearchObject(CandidateId: widget.candidate.id)),
        context.read<CVDocumentProvider>().get(filter: CVDocumentSearchObject(CandidateId: widget.candidate.id)),
        context.read<EducationProvider>().get(filter: EducationSearchObject(CandidateId: widget.candidate.id)),
        context.read<WorkExperienceProvider>().get(filter: WorkExperienceSearchObject(CandidateId: widget.candidate.id)),
        context.read<PreferencesProvider>().get(filter: PreferencesSearchObject(CandidateId: widget.candidate.id)),
      ]);

      if (mounted) {
        _candidateSkills = results[0].items?.cast<CandidateSkill>() ?? [];
        _cvDocuments = results[1].items?.cast<CVDocument>() ?? [];
        _education = results[2].items?.cast<Education>() ?? [];
        _workExperience = results[3].items?.cast<WorkExperience>() ?? [];
        final preferences = results[4].items?.cast<Preferences>();
        _preferences = preferences?.isNotEmpty == true ? preferences!.first : null;
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Candidate Details - ${widget.candidate.firstName} ${widget.candidate.lastName}",
      selectedRoute: '/admin-candidate-details',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("Failed to load candidate data", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchCandidateData, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildSkillsTab(),
              _buildCVTab(),
              _buildEducationTab(),
              _buildWorkExperienceTab(),
              _buildPreferencesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    '${widget.candidate.firstName[0]}${widget.candidate.lastName[0]}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.candidate.firstName} ${widget.candidate.lastName}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (widget.candidate.title != null)
                        Text(widget.candidate.title!, style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.candidate.email, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Chip(
                  label: Text(widget.candidate.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: widget.candidate.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  side: BorderSide(color: widget.candidate.isActive ? Colors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(icon: const Icon(Icons.person), text: 'Overview'),
                Tab(icon: const Icon(Icons.psychology), text: 'Skills (${_candidateSkills.length})'),
                Tab(icon: const Icon(Icons.description), text: 'CV (${_cvDocuments.length})'),
                Tab(icon: const Icon(Icons.school), text: 'Education (${_education.length})'),
                Tab(icon: const Icon(Icons.work), text: 'Experience (${_workExperience.length})'),
                Tab(icon: const Icon(Icons.settings), text: 'Preferences'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Information', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildInfoRow('Email', widget.candidate.email),
                  _buildInfoRow('Phone', widget.candidate.phoneNumber ?? 'Not provided'),
                  _buildInfoRow('Location', widget.candidate.locationName ?? 'Not specified'),
                  _buildInfoRow('Experience Level', experienceLevelToString(widget.candidate.experienceLevel)),
                  _buildInfoRow('Years of Experience', '${widget.candidate.experienceYears} years'),
                  _buildInfoRow('Registration Date', DateFormat.yMMMd().format(widget.candidate.registrationDate)),
                  _buildInfoRow('Status', widget.candidate.isActive ? 'Active' : 'Inactive'),
                ],
              ),
            ),
          ),
          if (widget.candidate.bio != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bio', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Text(widget.candidate.bio!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                Text('${_candidateSkills.length} skills', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (_candidateSkills.isEmpty)
              const Center(child: Text('No skills added yet'))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _candidateSkills.map((candidateSkill) => Chip(
                  label: Text(candidateSkill.skillName ?? 'Unknown Skill'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  side: BorderSide(color: AppTheme.primaryColor),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CV Documents', style: Theme.of(context).textTheme.titleLarge),
                Text('${_cvDocuments.length} documents', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (_cvDocuments.isEmpty)
              const Center(child: Text('No CV documents uploaded'))
            else
              Column(
                children: _cvDocuments.map((cv) => ListTile(
                  leading: const Icon(Icons.description, color: Colors.red),
                  title: Text(cv.fileName ?? 'CV Document'),
                  subtitle: Text('Uploaded: ${DateFormat.yMMMd().format(cv.uploadDate)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View CV',
                        onPressed: () => _viewCV(cv),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download CV',
                        onPressed: () => _downloadCV(cv),
                      ),
                    ],
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Education', style: Theme.of(context).textTheme.titleLarge),
                Text('${_education.length} entries', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (_education.isEmpty)
              const Center(child: Text('No education records found'))
            else
              Column(
                children: _education.map((edu) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: Text(edu.degree ?? 'Degree'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu.institution ?? 'Institution'),
                        if (edu.startDate != null || edu.endDate != null)
                          Text(
                            '${edu.startDate != null ? DateFormat.yMMMd().format(edu.startDate!) : 'Start'} - ${edu.endDate != null ? DateFormat.yMMMd().format(edu.endDate!) : 'Present'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkExperienceTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Work Experience', style: Theme.of(context).textTheme.titleLarge),
                Text('${_workExperience.length} positions', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (_workExperience.isEmpty)
              const Center(child: Text('No work experience found'))
            else
              Column(
                children: _workExperience.map((work) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.work, color: Colors.green),
                    title: Text(work.position ?? 'Job Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(work.companyName ?? 'Company'),
                        if (work.startDate != null || work.endDate != null)
                          Text(
                            '${work.startDate != null ? DateFormat.yMMMd().format(work.startDate!) : 'Start'} - ${work.endDate != null ? DateFormat.yMMMd().format(work.endDate!) : 'Present'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (work.description != null && work.description!.isNotEmpty)
                          Text(
                            work.description!,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Preferences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_preferences == null)
              const Center(child: Text('No preferences set'))
            else
              Column(
                children: [
                  _buildInfoRow('Preferred Location', _preferences!.locationName ?? 'Not specified'),
                  _buildInfoRow('Employment Type', _preferences!.employmentType != null ? employmentTypeToString(_preferences!.employmentType!) : 'Not specified'),
                  _buildInfoRow('Remote Work', _preferences!.remote != null ? remoteToString(_preferences!.remote!) : 'Not specified'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _viewCV(CVDocument cv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          title: cv.fileName ?? 'CV Document',
          pdfBytes: base64Decode(cv.fileContent),
        ),
      ),
    );
  }

  void _downloadCV(CVDocument cv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download functionality for ${cv.fileName ?? 'CV'} coming soon')),
    );
  }
}
