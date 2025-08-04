import 'package:flutter/material.dart';
import 'package:itapply_mobile/models/search_objects/review_search_object.dart';
import 'package:provider/provider.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/review.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/providers/review_provider.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/screens/review_dialog.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:intl/intl.dart';

class EmployerReviewsScreen extends StatefulWidget {
  final int employerId;
  final String companyName;
  final bool isGuest;

  const EmployerReviewsScreen({
    super.key,
    required this.employerId,
    required this.companyName,
    this.isGuest = false,
  });

  @override
  State<EmployerReviewsScreen> createState() => _EmployerReviewsScreenState();
}

class _EmployerReviewsScreenState extends State<EmployerReviewsScreen> {
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = true;
  bool _hasUserReviewed = false;
  bool _reviewAdded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final allReviews = await reviewProvider.getByEmployerId(widget.employerId);
      _reviews = allReviews.where((review) => review.moderationStatus == ModerationStatus.approved).toList();
      
      if (_reviews.isNotEmpty) {
        try {
          _averageRating = await reviewProvider.getAverageRatingForEmployer(widget.employerId);
        } catch (e) {
          _averageRating = _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
        }
      } else {
        _averageRating = 0.0;
      }

      if (!widget.isGuest && authProvider.currentCandidate != null) {
        final reviews = await reviewProvider.get(filter: ReviewSearchObject(EmployerId: widget.employerId, CandidateId: authProvider.currentCandidate!.id, RetrieveAll: true));
        _hasUserReviewed = reviews.items?.any((review) => review.candidateId == authProvider.currentCandidate!.id) ?? false;
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

  void _showAddReviewDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (widget.isGuest || authProvider.currentCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add a review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasUserReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already reviewed this employer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReviewDialog(
        employerId: widget.employerId,
        companyName: widget.companyName,
        candidate: authProvider.currentCandidate!,
        onReviewAdded: () {
          _loadReviews();
        },
      ),
    );
    
    if (result == true) {
      _reviewAdded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pop(_reviewAdded ? true : null);
        }
      },
      child: MasterScreen(
        showBackButton: true,
        selectedIndex: 2,
        title: 'Employer Reviews',
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
            'Failed to load reviews',
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
            onPressed: _loadReviews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.companyName} Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildOverallRating(),
                      const SizedBox(height: 8),
                      if (!widget.isGuest && !_hasUserReviewed)
                        ElevatedButton.icon(
                          onPressed: _showAddReviewDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if (_hasUserReviewed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Wrap(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'You have reviewed this company',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    if (_reviews.isEmpty) {
      return Wrap(
        children: [
          Icon(
            Icons.star_outline,
            size: 20,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      );
    }

    return Wrap(
      children: [
        _buildStarRating(_averageRating),
        const SizedBox(width: 12),
        Text(
          '${_averageRating.toStringAsFixed(1)} out of 5',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${_reviews.length} review${_reviews.length != 1 ? 's' : ''})',
          style: TextStyle(
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Wrap(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: 20,
            color: Colors.amber,
          );
        } else if (index < rating) {
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

  Widget _buildReviewsList() {
    if (_reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Reviews',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to review ${widget.companyName}',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (!widget.isGuest && !_hasUserReviewed) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.grayColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          _buildStarRating(review.rating.toDouble()),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: reviewRelationshipColor(review.relationship).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: reviewRelationshipColor(review.relationship).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              reviewRelationshipToString(review.relationship),
                              style: TextStyle(
                                fontSize: 12,
                                color: reviewRelationshipColor(review.relationship),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: [
                          if (review.candidateName != null) ...[
                            Text(
                              review.candidateName!,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (review.position != null) ...[
                              Text(
                                ' • ${review.position}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ] else if (review.position != null) ...[
                            Text(
                              review.position!,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            Text(
                  DateFormat('MMM dd, yyyy').format(review.reviewDate),
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 12,
                  ),
                ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
