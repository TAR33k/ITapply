import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/candidate_skill.dart';
import 'package:itapply_desktop/models/cv_document.dart';
import 'package:itapply_desktop/models/education.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/preferences.dart';
import 'package:itapply_desktop/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/education_search_object.dart';
import 'package:itapply_desktop/models/search_objects/preferences_search_object.dart';
import 'package:itapply_desktop/models/search_objects/work_experience_search_object.dart';
import 'package:itapply_desktop/models/work_experience.dart';
import 'package:itapply_desktop/providers/candidate_provider.dart';
import 'package:itapply_desktop/providers/candidate_skill_provider.dart';
import 'package:itapply_desktop/providers/cv_document_provider.dart';
import 'package:itapply_desktop/providers/education_provider.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/preferences_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/providers/work_experience_provider.dart';
import 'package:itapply_desktop/widgets/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AdminApplicationDetailsScreen extends StatefulWidget {
  final Application? application;

  const AdminApplicationDetailsScreen({super.key, required this.application});

  @override
  State<AdminApplicationDetailsScreen> createState() =>
      _AdminApplicationDetailsScreenState();
}

class _AdminApplicationDetailsScreenState
    extends State<AdminApplicationDetailsScreen> {
  bool _isLoading = true;
  String? _error;

  late Application _application;
  Candidate? _candidate;
  JobPosting? _jobPosting;
  Employer? _employer;
  List<CandidateSkill> _skills = [];
  List<WorkExperience> _workExperiences = [];
  List<Education> _educations = [];
  Preferences? _preferences;
  CVDocument? _cvDocument;

  @override
  void initState() {
    super.initState();
    _application = widget.application!;
    _fetchApplicationDetails();
  }

  Future<void> _fetchApplicationDetails() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final candidateId = _application.candidateId;
      final jobPostingId = _application.jobPostingId;
      final cvDocumentId = _application.cvDocumentId;

      final results = await Future.wait([
        context.read<CandidateProvider>().getById(candidateId),
        context.read<JobPostingProvider>().getById(jobPostingId),
        context.read<CVDocumentProvider>().getById(cvDocumentId),
      ]);

      final workExpResults = await context.read<WorkExperienceProvider>().get(filter: WorkExperienceSearchObject(CandidateId: candidateId, RetrieveAll: true));
      final educationResults = await context.read<EducationProvider>().get(filter: EducationSearchObject(CandidateId: candidateId, RetrieveAll: true));
      final skillResults = await context.read<CandidateSkillProvider>().get(filter: CandidateSkillSearchObject(CandidateId: candidateId, RetrieveAll: true));
      final preferenceResults = await context.read<PreferencesProvider>().get(filter: PreferencesSearchObject(CandidateId: candidateId, RetrieveAll: true));

      if (!mounted) return;

      final candidate = results[0] as Candidate?;
      final jobPosting = results[1] as JobPosting?;
      
      Employer? employer;
      if (jobPosting?.employerId != null) {
        employer = await context.read<EmployerProvider>().getById(jobPosting!.employerId);
      }

      if (!mounted) return;

      setState(() {
        _candidate = candidate;
        _jobPosting = jobPosting;
        _cvDocument = results[2] as CVDocument?;
        _workExperiences = (workExpResults.items as List<WorkExperience>)..sort((a, b) => b.startDate.compareTo(a.startDate));
        _educations = (educationResults.items as List<Education>)..sort((a, b) => b.startDate.compareTo(a.startDate));
        _skills = (skillResults.items as List<CandidateSkill>);
        final prefsList = (preferenceResults.items as List<Preferences>);
        _preferences = prefsList.isNotEmpty ? prefsList.first : null;
        _employer = employer;
      });

    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Application Details",
      selectedRoute: AppRouter.adminApplicationsRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMainContent()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildSidePanel()),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("Failed to load application details", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchApplicationDetails, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Back to All Applications"),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBackButton(),
          _buildCandidateInfo(),
          const SizedBox(height: 24),
          if (_skills.isNotEmpty) ...[ _buildSkillsSection(), const SizedBox(height: 24)],
          if (_cvDocument != null) ...[ _buildCVSection(), const SizedBox(height: 24)],
          if (_application.coverLetter?.isNotEmpty == true) ...[ _buildCoverLetter(), const SizedBox(height: 24)],
          if (_workExperiences.isNotEmpty) ...[ _buildWorkExperienceSection(), const SizedBox(height: 24)],
          if (_educations.isNotEmpty) ...[ _buildEducationSection(), const SizedBox(height: 24)],
          if (_preferences != null) _buildPreferencesSection(),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusInfo(),
          const SizedBox(height: 24),
          if (_jobPosting != null) ...[_buildJobPostingInfo(), const SizedBox(height: 24)],
          _buildActionPanel(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to All Applications"),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCandidateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Candidate Information", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            if (_candidate != null) ...[
              _buildInfoRow("Full Name", "${_candidate!.firstName} ${_candidate!.lastName}"),
              _buildInfoRow("Title", _candidate!.title ?? 'N/A'),
              _buildInfoRow("Experience Level", experienceLevelToString(_candidate!.experienceLevel)),
              _buildInfoRow("Experience Years", _candidate!.experienceYears.toString()),
              _buildInfoRow("Email", _candidate!.email),
              _buildInfoRow("Phone", _candidate!.phoneNumber ?? 'N/A'),
              _buildInfoRow("Location", _candidate!.locationName ?? 'N/A'),
              _buildInfoRow("Summary", _candidate!.bio ?? 'No summary provided.'),
            ] else
              const Text("Loading candidate information..."),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Skills", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((s) => Chip(
                label: Text("${s.skillName ?? ''} - Level ${s.level}", style: TextStyle(color: AppTheme.lightColor, fontWeight: FontWeight.bold)),
                shape: const StadiumBorder(side: BorderSide.none),
                backgroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: AppTheme.primaryColor)
              )).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCVSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Curriculum Vitae", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.description, size: 48, color: Colors.red),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cvDocument!.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text("PDF Document", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewCV(_cvDocument!),
                  icon: const Icon(Icons.visibility),
                  label: const Text("View"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _downloadCV(_cvDocument!),
                  icon: const Icon(Icons.download),
                  label: const Text("Download"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverLetter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cover Letter", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            Text(_application.coverLetter!, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkExperienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Work Experience", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            ..._workExperiences.asMap().entries.map((entry) {
              final isFirst = entry.key == 0;
              final isLast = entry.key == _workExperiences.length - 1;
              final exp = entry.value;
              return TimelineTile(
                isFirst: isFirst,
                isLast: isLast,
                beforeLineStyle: const LineStyle(color: AppTheme.grayColor),
                indicatorStyle: const IndicatorStyle(
                  width: 20,
                  color: AppTheme.primaryColor,
                  indicatorXY: 0,
                  padding: EdgeInsets.all(4)
                ),
                endChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${DateFormat.yMMM().format(exp.startDate)} - ${exp.endDate != null ? DateFormat.yMMM().format(exp.endDate!) : 'Present'}", style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(exp.position, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(exp.companyName, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.secondaryColor)),
                      if (exp.description != null && exp.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(exp.description!),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Education", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
             ..._educations.asMap().entries.map((entry) {
              final isFirst = entry.key == 0;
              final isLast = entry.key == _educations.length - 1;
              final edu = entry.value;
              return TimelineTile(
                isFirst: isFirst,
                isLast: isLast,
                beforeLineStyle: const LineStyle(color: AppTheme.grayColor),
                indicatorStyle: const IndicatorStyle(
                  width: 20,
                  color: AppTheme.primaryColor,
                  indicatorXY: 0,
                  padding: EdgeInsets.all(4)
                ),
                endChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${DateFormat.yMMM().format(edu.startDate)} - ${edu.endDate != null ? DateFormat.yMMM().format(edu.endDate!) : 'Present'}", style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(edu.degree, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(edu.institution, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.secondaryColor)),
                      Text(edu.fieldOfStudy, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryColor)),
                      if (edu.description != null && edu.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(edu.description!),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Preferences", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            if (_preferences?.employmentType != null) 
              _buildInfoRow("Employment Type", employmentTypeToString(_preferences!.employmentType!)),
            if (_preferences?.locationName != null && _preferences!.locationName!.isNotEmpty)
              _buildInfoRow("Location", _preferences!.locationName!),
            if (_preferences?.remote != null)
              _buildInfoRow("Remote", remoteToString(_preferences!.remote!)),
          ],
        ),
      )
    );
  }

  Widget _buildJobPostingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Job Posting Details", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            _buildInfoRow("Position", _jobPosting!.title),
            _buildInfoRow("Company", _employer?.companyName ?? 'N/A'),
            _buildInfoRow("Posted", DateFormat.yMMMd().format(_jobPosting!.postedDate)),
            _buildInfoRow("Deadline", DateFormat.yMMMd().format(_jobPosting!.applicationDeadline)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Application Overview", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            _buildInfoRow("Status", applicationStatusToString(_application.status)),
            _buildInfoRow("Application Date", DateFormat.yMMMd().format(_application.applicationDate)),
            if (_application.employerMessage?.isNotEmpty == true)
              _buildInfoRow("Message from Employer", _application.employerMessage!),
            if (_application.internalNotes?.isNotEmpty == true)
              _buildInfoRow("Internal Notes", _application.internalNotes!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Admin Actions", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (_candidate != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.adminCandidateDetailsRoute, arguments: _candidate),
                icon: const Icon(Icons.person_search),
                label: const Text("View Candidate Profile"),
              ),
            const SizedBox(height: 12),
            if (_employer != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.adminEmployerDetailsRoute, arguments: _employer),
                icon: const Icon(Icons.business_center_outlined),
                label: const Text("View Employer Profile"),
              ),
            const SizedBox(height: 12),
            if (_jobPosting != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.adminJobPostingDetailsRoute, arguments: _jobPosting),
                icon: const Icon(Icons.work),
                label: const Text("View Job Posting"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewCV(CVDocument cv) async {
    try {
      final Uint8List pdfBytes = base64Decode(cv.fileContent);
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.9,
            child: PdfViewerScreen(pdfBytes: pdfBytes, title: cv.fileName),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error viewing CV: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadCV(CVDocument cv) async {
    try {
      final Uint8List fileBytes = base64Decode(cv.fileContent);
      final result = await FileSaver.instance.saveFile(name: cv.fileName, bytes: fileBytes, mimeType: MimeType.pdf);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Downloaded CV at: $result"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading CV: $e"), backgroundColor: Colors.red));
      }
    }
  }
}