import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/cv_document.dart';
import 'package:itapply_mobile/models/requests/application_insert_request.dart';
import 'package:itapply_mobile/providers/application_provider.dart';

class ApplyDialog extends StatefulWidget {
  final JobPosting jobPosting;
  final Candidate candidate;
  final List<CVDocument> cvDocuments;

  const ApplyDialog({
    super.key,
    required this.jobPosting,
    required this.candidate,
    required this.cvDocuments,
  });

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _availabilityController = TextEditingController();
  
  CVDocument? _selectedCV;
  bool _receiveNotifications = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCV = widget.cvDocuments.firstWhere(
      (cv) => cv.isMain,
      orElse: () => widget.cvDocuments.first,
    );
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate() || _selectedCV == null) return;

    setState(() => _isSubmitting = true);

    try {
      final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);
      
      final request = ApplicationInsertRequest(
        candidateId: widget.candidate.id,
        jobPostingId: widget.jobPosting.id,
        coverLetter: _coverLetterController.text.trim(),
        cvDocumentId: _selectedCV!.id,
        availability: _availabilityController.text.trim(),
        receiveNotifications: _receiveNotifications,
      );

      await applicationProvider.insert(request);
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
          minHeight: 400,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.send, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Apply for Position',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.jobPosting.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select CV',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<CVDocument>(
                        isExpanded: true,
                        value: _selectedCV,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: widget.cvDocuments.map((cv) {
                          return DropdownMenuItem(
                            value: cv,
                            child: Row(
                              children: [
                                Icon(
                                  cv.isMain ? Icons.star : Icons.description,
                                  size: 20,
                                  color: cv.isMain ? Colors.amber : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    cv.fileName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (cv.isMain)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Main',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (cv) => setState(() => _selectedCV = cv),
                        validator: (value) => value == null ? 'Please select a CV' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cover Letter *',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _coverLetterController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Write a brief cover letter explaining why you\'re interested in this position...',
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: 4,
                        maxLength: 1000,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a cover letter' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Availability *',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _availabilityController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Immediately, 2 weeks notice, 1 month notice...',
                          contentPadding: EdgeInsets.all(12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please specify your availability';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        activeColor: AppTheme.primaryColor,
                        value: _receiveNotifications,
                        onChanged: (value) => setState(() => _receiveNotifications = value ?? true),
                        title: const Text('Receive email notifications'),
                        subtitle: const Text('Get updates on your application status'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
