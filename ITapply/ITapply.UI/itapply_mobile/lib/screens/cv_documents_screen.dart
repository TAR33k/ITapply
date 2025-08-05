import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:intl/intl.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/cv_document.dart';
import 'package:itapply_mobile/models/requests/cv_document_insert_request.dart';
import 'package:itapply_mobile/models/requests/cv_document_update_request.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/providers/cv_document_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class CVDocumentsScreen extends StatefulWidget {
  const CVDocumentsScreen({super.key});

  @override
  State<CVDocumentsScreen> createState() => _CVDocumentsScreenState();
}

class _CVDocumentsScreenState extends State<CVDocumentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<CVDocument> _cvDocuments = [];
  Candidate? _candidate;
  static const int maxCvCount = 5;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      _candidate = authProvider.currentCandidate;

      if (_candidate == null) {
        throw Exception("User is not logged in or is not a candidate.");
      }

      _cvDocuments = await context.read<CVDocumentProvider>().getByCandidateId(_candidate!.id);
    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? AppTheme.accentColor : AppTheme.confirmColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDelete(CVDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete CV?"),
        content: Text("Are you sure you want to delete '${document.fileName}'? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel", style: TextStyle(color: AppTheme.primaryColor))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<CVDocumentProvider>().delete(document.id);
        _showFeedback("CV deleted successfully.");
        await _fetchData();
      } catch (e) {
        if (e.toString().contains("currently used in job applications")) {
          _showFeedback("Error: This CV is used in one or more applications and cannot be deleted.", isError: true);
        } else {
          _showFeedback("Error deleting CV: $e", isError: true);
        }
      }
    }
  }

  Future<void> _handleSetAsMain(CVDocument document) async {
    try {
      await context.read<CVDocumentProvider>().setAsMain(document.id);
      _showFeedback("'${document.fileName}' is now your main CV.");
      await _fetchData();
    } catch (e) {
      _showFeedback("Error setting main CV: $e", isError: true);
    }
  }

  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    PermissionStatus status;

    if (deviceInfo.version.sdkInt >= 33) {
      status = PermissionStatus.granted;
    } else {
      status = await Permission.storage.request();
    }
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  Future<void> _handleView(CVDocument document) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      _showFeedback("Storage permission is required to view documents.", isError: true);
      return;
    }

    try {
      final bytes = base64Decode(document.fileContent);
      
      final dir = await getTemporaryDirectory();
      
      final sanitizedFileName = document.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final filePath = '${dir.path}/$sanitizedFileName';
      final file = File(filePath);
      
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        _showFeedback(result.message, isError: true);
      }
    } catch (e) {
      _showFeedback("Error viewing document: $e", isError: true);
    }
  }

  Future<void> _showAddEditDialog({CVDocument? document}) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => _CVDocumentDialog(
        candidateId: _candidate!.id,
        document: document,
        showFeedback: _showFeedback,
      ),
    );
    if (result != null) {
      _showFeedback(result);
      await _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Manage CVs",
      selectedIndex: 3,
      showBackButton: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    bool canUpload = _cvDocuments.length < maxCvCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(canUpload),
        const SizedBox(height: 16),
        if (_cvDocuments.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cvDocuments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _buildCVCard(_cvDocuments[index]),
          ),
      ],
    );
  }

  Widget _buildHeader(bool canUpload) {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your Documents", style: Theme.of(context).textTheme.titleLarge),
                if (canUpload)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                    onPressed: () => _showAddEditDialog(),
                    tooltip: "Upload new CV",
                  )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "You have uploaded ${_cvDocuments.length} out of $maxCvCount CVs.",
              style: const TextStyle(color: AppTheme.secondaryColor),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _cvDocuments.length / maxCvCount,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _cvDocuments.length == maxCvCount ? AppTheme.accentColor : AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            if (!canUpload) ...[
              const SizedBox(height: 12),
              Text(
                "You have reached the maximum number of CVs. Please delete one to upload a new document.",
                style: TextStyle(color: AppTheme.accentColor.withOpacity(0.8), fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No CVs Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text("Upload your first CV to get started.", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildCVCard(CVDocument document) {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.article_outlined, color: AppTheme.primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Uploaded: ${DateFormat.yMMMd().format(document.uploadDate)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (document.isMain)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.star, color: Colors.amber[600], size: 20),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') _handleView(document);
                if (value == 'edit') _showAddEditDialog(document: document);
                if (value == 'set_main') _handleSetAsMain(document);
                if (value == 'delete') _handleDelete(document);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'view',
                  child: ListTile(leading: Icon(Icons.visibility), title: Text('View')),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                ),
                if (!document.isMain)
                  const PopupMenuItem<String>(
                    value: 'set_main',
                    child: ListTile(leading: Icon(Icons.star_border), title: Text('Set as Main')),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline, color: AppTheme.accentColor), title: Text('Delete', style: TextStyle(color: AppTheme.accentColor))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CVDocumentDialog extends StatefulWidget {
  final int candidateId;
  final CVDocument? document;
  final void Function(String message, {bool isError}) showFeedback;

  const _CVDocumentDialog({
    required this.candidateId,
    this.document,
    required this.showFeedback,
  });

  @override
  State<_CVDocumentDialog> createState() => _CVDocumentDialogState();
}

class _CVDocumentDialogState extends State<_CVDocumentDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _pickedFileName;
  String? _pickedFileContent;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _pickedFileName = widget.document!.fileName;
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pickedFileName = result.files.single.name;
          _pickedFileContent = base64Encode(result.files.single.bytes!);
          _formKey.currentState?.patchValue({'fileName': _pickedFileName});
        });
      }
    } catch (e) {
      widget.showFeedback("Error picking file: $e", isError: true);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    if (widget.document == null && _pickedFileContent == null) {
      widget.showFeedback("Please select a PDF file to upload.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final formData = _formKey.currentState!.value;

    try {
      var fileName = formData['fileName'];
      if (!fileName.endsWith(".pdf")) {
        fileName += ".pdf";
      }

      if (widget.document == null) {
        final request = CVDocumentInsertRequest(
          candidateId: widget.candidateId,
          fileName: fileName,
          fileContent: _pickedFileContent!,
          isMain: formData['isMain'],
        );
        await context.read<CVDocumentProvider>().insert(request);
        if (mounted) Navigator.of(context).pop("CV uploaded successfully.");
      } else {
        final request = CVDocumentUpdateRequest(
          fileName: fileName,
          fileContent: _pickedFileContent,
          isMain: formData['isMain'],
        );
        await context.read<CVDocumentProvider>().update(widget.document!.id, request);
        if (mounted) Navigator.of(context).pop("CV updated successfully.");
      }
    } catch (e) {
      widget.showFeedback("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.document != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit CV" : "Upload CV"),
      content: FormBuilder(
        key: _formKey,
        initialValue: {
          'fileName': widget.document?.fileName,
          'isMain': widget.document?.isMain ?? false,
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'fileName',
                decoration: const InputDecoration(labelText: "Document Name"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(100),
                ]),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(isEditing ? "Change PDF File" : "Select PDF File"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 8),
              if (_pickedFileName != null)
                Text("Selected: $_pickedFileName", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              FormBuilderCheckbox(
                activeColor: AppTheme.primaryColor,
                name: 'isMain',
                title: const Text("Make this my main CV"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text("Cancel", style: TextStyle(color: AppTheme.primaryColor))),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Save"),
        ),
      ],
    );
  }
}