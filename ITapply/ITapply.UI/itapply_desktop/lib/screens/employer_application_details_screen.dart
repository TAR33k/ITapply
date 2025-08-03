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
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/preferences.dart';
import 'package:itapply_desktop/models/requests/application_update_request.dart';
import 'package:itapply_desktop/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/education_search_object.dart';
import 'package:itapply_desktop/models/search_objects/preferences_search_object.dart';
import 'package:itapply_desktop/models/search_objects/work_experience_search_object.dart';
import 'package:itapply_desktop/models/work_experience.dart';
import 'package:itapply_desktop/providers/application_provider.dart';
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

class EmployerApplicationDetailsScreen extends StatefulWidget {
  final Application? application;

  const EmployerApplicationDetailsScreen({super.key, required this.application});

  @override
  State<EmployerApplicationDetailsScreen> createState() =>
      _EmployerApplicationDetailsScreenState();
}

class _EmployerApplicationDetailsScreenState
    extends State<EmployerApplicationDetailsScreen> {
  bool _isLoading = true;
  String? _error;
  bool _hasMadeChanges = false;

  late Application _application;
  Candidate? _candidate;
  JobPosting? _jobPosting;
  Employer? _employer;
  List<CandidateSkill> _skills = [];
  List<WorkExperience> _workExperiences = [];
  List<Education> _educations = [];
  Preferences? _preferences;
  CVDocument? _cvDocument;
  String? _candidateEmail;

  final _messageController = TextEditingController();
  final _notesController = TextEditingController();
  ApplicationStatus? _selectedStatus;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _application = widget.application!;
    _selectedStatus = _application.status;
    _notesController.text = _application.internalNotes ?? '';
    _fetchApplicationDetails();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchApplicationDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidateId = _application.candidateId;
      final jobPostingId = _application.jobPostingId;
      final cvDocumentId = _application.cvDocumentId;

      final results = await Future.wait([
        context.read<CandidateProvider>().getById(candidateId),
        context.read<JobPostingProvider>().getById(jobPostingId),
        context.read<CVDocumentProvider>().getById(cvDocumentId),
      ]);

      if (!mounted) return;
      final workExperiences = await context.read<WorkExperienceProvider>().get(
            filter: WorkExperienceSearchObject(
                CandidateId: candidateId, RetrieveAll: true));
      if (!mounted) return;
      final educations = await context.read<EducationProvider>().get(
            filter: EducationSearchObject(
                CandidateId: candidateId, RetrieveAll: true));
      if (!mounted) return;
      final skills = await context.read<CandidateSkillProvider>().get(
            filter: CandidateSkillSearchObject(
                CandidateId: candidateId, RetrieveAll: true));
      if (!mounted) return;
      final preferences = await context.read<PreferencesProvider>().get(
            filter: PreferencesSearchObject(
                CandidateId: candidateId, RetrieveAll: true));

      if (!mounted) return;

      setState(() {
        _candidate = results[0] as Candidate?;
        _jobPosting = results[1] as JobPosting?;
        _cvDocument = results[2] as CVDocument?;
        _candidateEmail = _application.candidateEmail;

        _workExperiences = (workExperiences.items as List<WorkExperience>)
          ..sort((a, b) => b.startDate.compareTo(a.startDate));

        _educations = (educations.items as List<Education>)
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
          
        _skills = skills.items as List<CandidateSkill>;
        
        final prefsList = preferences.items as List<Preferences>;
        _preferences = prefsList.isNotEmpty ? prefsList.first : null;
      });

      final employerId = _jobPosting?.employerId;
      if (employerId != null) {
        final employer = await context.read<EmployerProvider>().getById(employerId);
        if (mounted) {
          setState(() {
            _employer = employer;
          });
        }
      }
    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ApplicationStatus> _getValidStatusTransitions() {
    final currentStatus = _application.status;
    
    List<ApplicationStatus> validTransitions = [currentStatus];

    switch (currentStatus) {
      case ApplicationStatus.applied:
        validTransitions.addAll(ApplicationStatus.values.where((s) => s != ApplicationStatus.applied));
        break;
      case ApplicationStatus.inConsideration:
        validTransitions.addAll(ApplicationStatus.values.where((s) => s != ApplicationStatus.applied));
        break;
      case ApplicationStatus.interviewScheduled:
        validTransitions.addAll(ApplicationStatus.values.where((s) => s != ApplicationStatus.applied && s != ApplicationStatus.inConsideration));
        break;
      case ApplicationStatus.rejected:
        break;
      case ApplicationStatus.accepted:
        validTransitions.add(ApplicationStatus.rejected);
        break;
    }

    return validTransitions.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Application Details",
      selectedRoute: AppRouter.employerApplicationsRoute,
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
          Text("Failed to load application details",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _fetchApplicationDetails, child: const Text("Retry")),
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
          onPressed: () => Navigator.pop(context, _hasMadeChanges),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Back to All Applications"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () => Navigator.pop(context, _hasMadeChanges),
              child: const Text("Back to All Applications"),
            ),
          ],
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
          if (_skills.isNotEmpty) ...[
            _buildSkillsSection(),
            const SizedBox(height: 24),
          ],
          if (_cvDocument != null) ...[
             _buildCVSection(),
            const SizedBox(height: 24),
          ],
          if (_application.coverLetter?.isNotEmpty == true) ...[
            _buildCoverLetter(),
            const SizedBox(height: 24),
          ],
          _buildApplicationInfo(),
          const SizedBox(height: 24),
          if (_workExperiences.isNotEmpty) ...[
            _buildWorkExperienceSection(),
            const SizedBox(height: 24),
          ],
          if (_educations.isNotEmpty) ...[
            _buildEducationSection(),
            const SizedBox(height: 24),
          ],
          if (_preferences != null) ...[
            _buildPreferencesSection(),
          ]
        ],
      ),
    );
  }

  Widget _buildApplicationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Application Information", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            _buildInfoRow("Application Date", DateFormat.yMMMd().format(_application.applicationDate)),
            _buildInfoRow("Availability", _application.availability.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_jobPosting != null) ...[
            _buildJobPostingInfo(),
            const SizedBox(height: 24),
          ],
          _buildStatusAndMessageUpdate(),
          const SizedBox(height: 24),
          _buildInternalNotes(),
          const SizedBox(height: 24),
          _buildScheduleInterview(),
          const SizedBox(height: 24),
          _buildCancelButton(),
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
              _buildInfoRow("Email", _candidateEmail ?? 'N/A'),
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
            _buildInfoRow("Employment Type", employmentTypeToString(_jobPosting!.employmentType)),
            _buildInfoRow("Experience Level", experienceLevelToString(_jobPosting!.experienceLevel)),
            _buildInfoRow("Posted", DateFormat.yMMMd().format(_jobPosting!.postedDate)),
            _buildInfoRow("Deadline", DateFormat.yMMMd().format(_jobPosting!.applicationDeadline)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAndMessageUpdate() {
    final validStatuses = _getValidStatusTransitions();

    final isStatusLocked = validStatuses.length <= 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Update Status & Notify", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            DropdownButtonFormField<ApplicationStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: "Application Status",
                border: const OutlineInputBorder(),
                filled: isStatusLocked,
                fillColor: isStatusLocked ? Colors.grey.shade200 : null,
              ),
              onChanged: isStatusLocked ? null : (value) => setState(() => _selectedStatus = value),
              items: validStatuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(applicationStatusToString(status)),
              )).toList(),
            ),
            if (isStatusLocked)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Status cannot be changed from '${applicationStatusToString(_application.status)}'.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Message to Candidate (Optional)",
                hintText: "This message will be sent to the candidate.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedStatus != _application.status || _messageController.text.isNotEmpty) && !isStatusLocked
                  ? _showUpdateConfirmationDialog
                  : null,
                icon: const Icon(Icons.send),
                label: const Text("Update & Notify"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternalNotes() {
    final hasNotes = _application.internalNotes?.isNotEmpty == true;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Internal Notes", style: Theme.of(context).textTheme.headlineSmall),
                if (hasNotes)
                  TextButton.icon(
                    onPressed: () {
                       if (_isEditingNotes) {
                        _notesController.text = _application.internalNotes ?? '';
                      }
                      setState(() => _isEditingNotes = !_isEditingNotes);
                    },
                    icon: Icon(_isEditingNotes ? Icons.close : Icons.edit, size: 18),
                    label: Text(_isEditingNotes ? "Cancel" : "Edit"),
                  ),
              ],
            ),
            const Divider(height: 24),
            if (hasNotes && !_isEditingNotes)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _application.internalNotes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: hasNotes ? "Edit your private notes..." : "Add private notes about this application...",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveInternalNotes,
                      child: const Text("Save Notes"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInterview() {
    final canSchedule = _getValidStatusTransitions().contains(ApplicationStatus.interviewScheduled);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Interview", style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSchedule ? _showScheduleInterviewDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSchedule ? AppTheme.confirmColor : Colors.grey,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                icon: const Icon(Icons.calendar_today, color: Colors.white,),
                label: const Text("Schedule Interview", style: TextStyle(color: Colors.white),),
              ),
            ),
             if (!canSchedule)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Cannot schedule an interview from the current status.",
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
            child: PdfViewerScreen(
              pdfBytes: pdfBytes,
              title: cv.fileName,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error viewing CV: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _downloadCV(CVDocument cv) async {
    try {
      final String cvContent = cv.fileContent;
      final Uint8List fileBytes = base64Decode(cvContent);
      final result = await FileSaver.instance.saveFile(
        name: cv.fileName,
        bytes: fileBytes,
        mimeType: MimeType.pdf
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloaded CV at: $result"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading CV: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showUpdateConfirmationDialog() async {
    final message = _messageController.text.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You are about to change the status to:", style: Theme.of(context).textTheme.bodySmall),
            Text(applicationStatusToString(_selectedStatus!), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("The following message will be sent:"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                child: Text(message, style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ] else ... [
              const SizedBox(height: 16),
              const Text("No message will be sent to the candidate."),
            ],
            const SizedBox(height: 16),
            const Text("Are you sure you want to proceed?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.confirmColor,
            ),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Confirm")),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateApplication(
        status: _selectedStatus!,
        message: message.isNotEmpty ? message : null,
      );
    }
  }

  Future<void> _saveInternalNotes() async {
    final notes = _notesController.text.trim();
    if (notes == (_application.internalNotes ?? '')) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No changes to save."),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    await _updateApplication(notes: notes);
    if(mounted) {
      setState(() {
        _isEditingNotes = false;
      });
    }
  }

  Future<void> _updateApplication({ApplicationStatus? status, String? message, String? notes}) async {
    try {
      final statusToSend = (status != null && status != _application.status) ? status : null;

      if (statusToSend != null && message == null) {
        message = "";
      }

      final request = ApplicationUpdateRequest(
        status: statusToSend,
        employerMessage: message,
        internalNotes: notes
      );

      final updatedApplication = await context.read<ApplicationProvider>().update(_application.id, request);
      
      if (mounted) {
        _hasMadeChanges = true;

        setState(() {
           _application = updatedApplication;
           _selectedStatus = _application.status;
           _notesController.text = _application.internalNotes ?? '';
           _messageController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating application: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showScheduleInterviewDialog({
    DateTime? initialDate,
    TimeOfDay? initialTime,
    String? initialType,
    String? initialAddress,
    String? initialInfo,
  }) async {
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDate = initialDate;
    TimeOfDay? selectedTime = initialTime;
    String interviewType = initialType ?? 'online';
    
    String defaultAddress = _employer?.address ?? 'Company Address, 123 Office Park, City';
    final addressController = TextEditingController(text: initialAddress ?? defaultAddress);
    final infoController = TextEditingController(text: initialInfo ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Schedule Interview"),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Date"),
                      subtitle: Text(selectedDate != null ? DateFormat.yMMMd().format(selectedDate!) : "Select a date"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setDialogState(() => selectedDate = date);
                      },
                    ),
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime != null ? selectedTime!.format(context) : "Select a time"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: selectedTime ?? const TimeOfDay(hour: 10, minute: 0));
                        if (time != null) setDialogState(() => selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: interviewType,
                      decoration: const InputDecoration(labelText: "Interview Type"),
                      items: const [
                        DropdownMenuItem(value: 'online', child: Text('Online Meeting')),
                        DropdownMenuItem(value: 'in_office', child: Text('In-Person at Office')),
                      ],
                      onChanged: (value) => setDialogState(() => interviewType = value!),
                    ),
                    if (interviewType == 'in_office') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Interview Address", border: OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: infoController,
                      decoration: const InputDecoration(labelText: "Additional Information (Optional)", hintText: "e.g., Please bring your portfolio.", border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: selectedDate != null && selectedTime != null
                  ? () {
                      Navigator.pop(context);
                      _confirmAndScheduleInterview(selectedDate!, selectedTime!, interviewType, addressController.text, infoController.text);
                    }
                  : null,
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndScheduleInterview(DateTime date, TimeOfDay time, String type, String address, String additionalInfo) async {
    final message = _generateInterviewMessage(date, time, type, address, additionalInfo);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Interview Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("The application status will be changed to 'Interview Scheduled' and the following message will be sent to the candidate:"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.maxFinite,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              _showScheduleInterviewDialog(
                initialDate: date,
                initialTime: time,
                initialType: type,
                initialAddress: address,
                initialInfo: additionalInfo,
              );
            }, 
            child: const Text("Back")
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Confirm & Send Invitation"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateApplication(status: ApplicationStatus.interviewScheduled, message: message);
    }
  }

  String _generateInterviewMessage(DateTime date, TimeOfDay time, String type, String address, String additionalInfo) {
    final dateStr = DateFormat.yMMMMd().format(date);
    final timeStr = time.format(context);
    final candidateName = "${_candidate?.firstName}";
    final jobTitle = _jobPosting?.title ?? 'the position';
    
    String message = "Dear $candidateName,\n\n";
    message += "Thank you for your interest in the $jobTitle role. We were impressed with your application and would like to invite you for an interview.\n\n";
    message += "Here are the details:\n";
    message += "• Date: $dateStr\n";
    message += "• Time: $timeStr\n";
    message += "• Type: ${type == 'online' ? 'Online Interview' : 'In-Person Interview'}\n";
    
    if (type == 'in_office') {
      message += "• Location: $address\n";
    }
    
    if (additionalInfo.isNotEmpty) {
      message += "\nAdditional Information:\n$additionalInfo\n";
    }
    
    message += "\nPlease let us know if this time works for you or if you need to reschedule. We look forward to speaking with you.\n\n";
    message += "Best regards,\nThe Hiring Team at ${_employer?.companyName}\n${_employer?.contactEmail}\n${_employer?.contactPhone}";
    message += "\n\nThis is an automated message, please do not reply to this email. For any questions, please contact ${_employer?.contactEmail}.";

    return message;
  }
}