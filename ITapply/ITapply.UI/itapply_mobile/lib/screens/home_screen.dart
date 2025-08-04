import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_mobile/widgets/job_card.dart';
import 'package:itapply_mobile/widgets/quick_filters.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;

  const HomeScreen({
    super.key,
    this.isGuest = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFilters = [];
  final bool _isLoading = false;
  bool _isInitialLoading = true;
  List<JobPosting> _jobs = [];
  List<JobPosting> _filteredJobs = [];
  // ignore: prefer_final_fields
  Map<int, Employer> _employerCache = {};
  String? _errorMessage;
  Candidate? _currentCandidate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isLoggedIn = user != null && !widget.isGuest;

    if (_isInitialLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text('Loading jobs...', style: TextStyle(color: AppTheme.textColor)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(isLoggedIn, user?.email),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildQuickFilters(),
        const SizedBox(height: 16),
        _buildJobsList(),
        if (!isLoggedIn) _buildGuestPrompt(),
      ],
    );
  }

  Widget _buildWelcomeSection(bool isLoggedIn, String? userEmail) {
    if (isLoggedIn) {
      final firstName = _currentCandidate?.firstName ?? 'User';
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $firstName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to find your next opportunity?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Find Your Perfect IT Job',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse hundreds of IT jobs from top employers',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.registrationRoute),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.loginRoute),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 16),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return HomeQuickFilters(
      selectedFilters: _selectedFilters,
      onFilterTap: (filter) {
        setState(() {
          if (_selectedFilters.contains(filter)) {
            _selectedFilters.remove(filter);
          } else {
            _selectedFilters.add(filter);
          }
          _performSearch();
        });
      },
    );
  }

  Widget _buildJobsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedFilters.isNotEmpty
                  ? 'No jobs found matching your criteria'
                  : 'No jobs available at the moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty || _selectedFilters.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedFilters.clear();
                    _filteredJobs = _jobs;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            Text(
              widget.isGuest || _currentCandidate == null
                  ? 'Job postings'
                  : 'Recommended for You',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            if (_filteredJobs.length > 5)
              TextButton(
                onPressed: () {    
                  Navigator.pushNamed(
                    context, 
                    AppRouter.jobListRoute, 
                    arguments: {
                      'isGuest': widget.isGuest,
                      'searchQuery': null,
                      'filters': null,
                    },
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredJobs.length,
          itemBuilder: (context, index) {
            final job = _filteredJobs[index];
            final employer = _employerCache[job.employerId];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(
                jobId: job.id,
                jobTitle: job.title,
                companyName: job.employerName,
                companyLogoBase64: employer?.logo,
                location: "${job.locationName} (${switch(job.remote){
                  Remote.yes => 'Remote',
                  Remote.hybrid => 'Hybrid',
                  Remote.no => 'On-site',
                }})",
                employmentType: job.employmentType,
                postedDate: job.postedDate,
                deadlineDate: job.applicationDeadline,
                skills: job.skills.map((skill) => skill.skillName).whereType<String>().toList(),
                isGuest: widget.isGuest,
                onTap: () async {
                    final result = await Navigator.pushNamed(
                    context,
                    AppRouter.jobDetailsRoute,
                    arguments: {'jobId': job.id, 'selectedIndex': 0},
                  );

                  if (result == true && mounted) {
                    _initializeData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              ),
            );
          },
        ),
        if (!widget.isGuest) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.jobListRoute);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Show More Jobs',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuestPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock Full Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to apply for jobs and get personalized recommendations.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.registrationRoute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.loginRoute),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    String? searchQuery;
    Map<String, dynamic>? filters;
    
    if (_searchController.text.isNotEmpty) {
      searchQuery = _searchController.text.trim();
    }
    
    if (_selectedFilters.isNotEmpty) {
      filters = {};
      searchQuery = _selectedFilters.join(" ");
    }
    
    Navigator.pushNamed(
      context, 
      AppRouter.jobListRoute, 
      arguments: {
        'isGuest': widget.isGuest,
        'searchQuery': searchQuery,
        'filters': filters,
      },
    );
  }

  Future<void> _initializeData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadUserData();
      await _loadJobs();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (widget.isGuest) return;
    
    final authProvider = context.read<AuthProvider>();
    
    _currentCandidate = authProvider.currentCandidate;
  }

  Future<void> _loadJobs() async {
    try {
      final jobProvider = context.read<JobPostingProvider>();
      List<JobPosting> jobs;
      
      if (!widget.isGuest && _currentCandidate != null) {
        jobs = await jobProvider.getRecommended(_currentCandidate!.id);
        
        if (jobs.isEmpty) {
          jobs = await _loadActiveJobs();
        }
      } else {
        jobs = await _loadActiveJobs();
      }
      
      await _loadEmployerData(jobs);
      
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
      });
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }

  Future<List<JobPosting>> _loadActiveJobs() async {
    final jobProvider = context.read<JobPostingProvider>();
    final searchObject = JobPostingSearchObject(
      Status: JobPostingStatus.active,
      PageSize: 10,
      Page: 0,
    );
    
    final result = await jobProvider.get(filter: searchObject);
    return result.items ?? [];
  }

  Future<void> _loadEmployerData(List<JobPosting> jobs) async {
    final employerProvider = context.read<EmployerProvider>();
    final employerIds = jobs.map((job) => job.employerId).toSet();
    
    for (final employerId in employerIds) {
      if (!_employerCache.containsKey(employerId)) {
        try {
          final employer = await employerProvider.getById(employerId);
          _employerCache[employerId] = employer;
        } catch (e) {
          debugPrint('Error loading employer $employerId: $e');
        }
      }
    }
  }
}