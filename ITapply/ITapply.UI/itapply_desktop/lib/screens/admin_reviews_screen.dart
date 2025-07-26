import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/requests/review_insert_request.dart';
import 'package:itapply_desktop/models/requests/review_update_request.dart';
import 'package:itapply_desktop/models/review.dart';
import 'package:itapply_desktop/models/search_objects/candidate_search_object.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/models/search_objects/review_search_object.dart';
import 'package:itapply_desktop/providers/candidate_provider.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/review_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key, this.candidateName, this.employerName});

  final String? candidateName;
  final String? employerName;

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  bool _isLoading = true;
  String? _error;

  List<Review> _reviews = [];
  List<Review> _filteredReviews = [];

  final _searchController = TextEditingController();
  ModerationStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    if (widget.candidateName != null && widget.candidateName!.isNotEmpty) {
      _searchController.text = widget.candidateName!;
    }
    else if (widget.employerName != null && widget.employerName!.isNotEmpty) {
      _searchController.text = widget.employerName!;
    }
    else {
      _searchController.text = "";
    }
    _fetchData();
    _searchController.addListener(_filterReviews);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await context.read<ReviewProvider>().get(filter: ReviewSearchObject(RetrieveAll: true));
      if (mounted) {
        setState(() {
          _reviews = result.items as List<Review>;
          _filterReviews();
        });
      }
    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterReviews() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredReviews = _reviews.where((review) {
        final matchesSearch = query.isEmpty ||
            (review.candidateName?.toLowerCase().contains(query) ?? false) ||
            (review.companyName?.toLowerCase().contains(query) ?? false);
        final matchesStatus = _selectedStatusFilter == null || review.moderationStatus == _selectedStatusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
      _filteredReviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
    });
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: isError ? "Operation Failed" : "Success",
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
    ).show(context);
  }

  Future<void> _handleModeration(Review review, ModerationStatus newStatus) async {
    final actionText = newStatus == ModerationStatus.approved ? "approve" : "reject";
    final actionColor = newStatus == ModerationStatus.approved ? Colors.green : Colors.red;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${actionText.substring(0, 1).toUpperCase()}${actionText.substring(1)} Review"),
        content: Text("Are you sure you want to $actionText this review by ${review.candidateName ?? 'Unknown'} about ${review.companyName ?? 'Unknown'}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(actionText.substring(0, 1).toUpperCase() + actionText.substring(1)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ReviewProvider>().updateModerationStatus(review.id, newStatus);
        _showFeedback("Review ${actionText}d successfully.");
        await _fetchData();
      } catch (e) {
        _showFeedback(e.toString(), isError: true);
      }
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to permanently delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ReviewProvider>().delete(review.id);
        _showFeedback("Review deleted successfully.");
        await _fetchData();
      } catch (e) {
        _showFeedback(e.toString(), isError: true);
      }
    }
  }

  Future<void> _addOrEditReview([Review? review]) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => _ReviewEditDialog(review: review),
    );
    if (success == true) {
      await _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Review Management",
      selectedRoute: AppRouter.adminReviewsRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDataTable(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by candidate or company name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<ModerationStatus?>(
                value: _selectedStatusFilter,
                decoration: const InputDecoration(
                  labelText: "Filter by Status",
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text("All Statuses")),
                  ...ModerationStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(moderationStatusToString(status)),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatusFilter = value);
                  _filterReviews();
                },
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () => _addOrEditReview(),
              icon: const Icon(Icons.add),
              label: const Text("Add Review"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Rating')),
              DataColumn(label: Text('Comment')),
              DataColumn(label: Text('Candidate')),
              DataColumn(label: Text('Company')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _filteredReviews.map((review) {
              return DataRow(cells: [
                DataCell(Row(
                  children: [
                    Text(review.rating.toString()),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                )),
                DataCell(SizedBox(width: 250, child: Text(review.comment ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis))),
                DataCell(Text("${review.candidateName ?? 'N/A'} (${reviewRelationshipToString(review.relationship)})")),
                DataCell(Text(review.companyName ?? 'N/A')),
                DataCell(Text(DateFormat.yMMMd().format(review.reviewDate))),
                DataCell(
                  Chip(
                    label: Text(moderationStatusToString(review.moderationStatus)),
                    backgroundColor: moderationStatusColor(review.moderationStatus).withOpacity(0.2),
                    side: BorderSide(color: moderationStatusColor(review.moderationStatus)),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      if (review.moderationStatus == ModerationStatus.pending) ...[
                        IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), tooltip: "Approve", onPressed: () => _handleModeration(review, ModerationStatus.approved)),
                        IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: "Reject", onPressed: () => _handleModeration(review, ModerationStatus.rejected)),
                      ],
                      IconButton(icon: const Icon(Icons.edit_outlined), tooltip: "Edit", onPressed: () => _addOrEditReview(review)),
                      IconButton(icon: const Icon(Icons.delete_outline), tooltip: "Delete", onPressed: () => _deleteReview(review)),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      );
  }
}

class _ReviewEditDialog extends StatefulWidget {
  final Review? review;
  const _ReviewEditDialog({this.review});

  @override
  State<_ReviewEditDialog> createState() => _ReviewEditDialogState();
}

class _ReviewEditDialogState extends State<_ReviewEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = true;

  List<Candidate> _candidates = [];
  List<Employer> _employers = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final results = await Future.wait([
        context.read<CandidateProvider>().get(filter: CandidateSearchObject(RetrieveAll: true)),
        context.read<EmployerProvider>().get(filter: EmployerSearchObject(RetrieveAll: true)),
      ]);
      if (mounted) {
        setState(() {
          _candidates = results[0].items as List<Candidate>;
          _employers = results[1].items as List<Employer>;
        });
      }
    } catch (e) {
      _showFeedback(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReview() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    setState(() => _isLoading = true);

    try {
      final formData = _formKey.currentState!.value;
      if (widget.review == null) {
        final request = ReviewInsertRequest(
          candidateId: formData['candidateId'],
          employerId: formData['employerId'],
          rating: formData['rating'],
          comment: formData['comment'],
          relationship: formData['relationship'],
          position: formData['position'],
        );
        await context.read<ReviewProvider>().insert(request);
        _showFeedback("Review created successfully.");
      } else {
        final request = ReviewUpdateRequest(
          rating: formData['rating'],
          comment: formData['comment'],
          relationship: formData['relationship'],
          position: formData['position'],
          moderationStatus: formData['moderationStatus'],
        );
        await context.read<ReviewProvider>().update(widget.review!.id, request);
        _showFeedback("Review updated successfully.");
      }
      if(mounted) Navigator.pop(context, true);
    } catch(e) {
      _showFeedback(e.toString(), isError: true);
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        Flushbar(
          title: isError ? "Operation Failed" : "Success",
          message: message,
          duration: const Duration(seconds: 1),
          backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
          icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
        ).show(context);
      }
    });
  }

  Map<String, dynamic> _getInitialValues() {
    if (widget.review == null) {
      return {};
    }
    final map = widget.review!.toJson();
    map['relationship'] = widget.review!.relationship;
    map['moderationStatus'] = widget.review!.moderationStatus;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.review == null ? "Add New Review" : "Edit Review"),
      content: SizedBox(
        width: 500,
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : FormBuilder(
          key: _formKey,
          initialValue: _getInitialValues(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderDropdown(
                  name: 'candidateId',
                  decoration: const InputDecoration(labelText: "Candidate"),
                  enabled: widget.review == null,
                  items: _candidates.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text("${c.firstName} ${c.lastName}"),
                  )).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown(
                  name: 'employerId',
                  decoration: const InputDecoration(labelText: "Employer"),
                  enabled: widget.review == null,
                  items: _employers.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.companyName),
                  )).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown(
                  name: 'rating',
                  decoration: const InputDecoration(labelText: "Rating"),
                  items: [1,2,3,4,5].map((r) => DropdownMenuItem(value: r, child: Text("$r Stars"))).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'comment',
                  decoration: const InputDecoration(labelText: "Comment", border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'position',
                  decoration: const InputDecoration(labelText: "Position at Company"),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown(
                  name: 'relationship',
                  decoration: const InputDecoration(labelText: "Relationship with Company"),
                  items: ReviewRelationship.values.map((r) => DropdownMenuItem(value: r, child: Text(reviewRelationshipToString(r)))).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                if (widget.review != null) ...[
                  const SizedBox(height: 16),
                  FormBuilderDropdown(
                    name: 'moderationStatus',
                    decoration: const InputDecoration(labelText: "Moderation Status"),
                    items: ModerationStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(moderationStatusToString(s)))).toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveReview,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Save"),
        ),
      ],
    );
  }
}