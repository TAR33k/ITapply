import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itapply_mobile/models/search_objects/skill_search_object.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/models/job_posting.dart';
import 'package:itapply_mobile/models/skill.dart';
import 'package:itapply_mobile/models/location.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_mobile/models/search_objects/location_search_object.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/providers/skill_provider.dart';
import 'package:itapply_mobile/providers/location_provider.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:itapply_mobile/widgets/job_card.dart';
import 'package:itapply_mobile/widgets/form_builder_chips.dart';
import 'package:itapply_mobile/config/app_router.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class JobListScreen extends StatefulWidget {
  final bool isGuest;
  final String? initialSearchQuery;
  final Map<String, dynamic>? initialFilters;

  const JobListScreen({
    super.key,
    this.isGuest = false,
    this.initialSearchQuery,
    this.initialFilters,
  });

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ignore: prefer_final_fields
  Map<int, Employer> _employerCache = {};
  final _debouncer = Debouncer(milliseconds: 500);

  bool _showFilters = false;
  List<JobPosting> _jobs = [];
  List<Skill> _allSkills = [];
  
  String _searchQuery = '';
  ExperienceLevel? _selectedExperience;
  EmploymentType? _selectedJobType;
  int? _selectedLocationId;
  Remote? _selectedRemoteWork;
  List<Skill> _selectedSkills = [];
  
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeFromParams();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeFromParams() {
    if (widget.initialSearchQuery != null) {
      _searchQuery = widget.initialSearchQuery!;
      _searchController.text = _searchQuery;
    }

    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      _selectedLocationId = filters['locationId'];
      _selectedSkills = List<Skill>.from(filters['skills'] ?? []);
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      await _loadSkills();
      await _loadJobs(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSkills() async {
    try {
      final skillProvider = Provider.of<SkillProvider>(context, listen: false);
      final result = await skillProvider.get(filter: SkillSearchObject(RetrieveAll: true));
      if (result.items != null) {
        setState(() => _allSkills = result.items!);
      }
    } catch (e) {
      debugPrint('Error loading skills: $e');
    }
  }

  Future<void> _loadJobs({bool reset = false}) async {
    if (!reset && (_isLoading || !_hasMoreData)) return;
    
    if (!reset) {
      setState(() => _isLoading = true);
    }
    
    try {
      final jobProvider = Provider.of<JobPostingProvider>(context, listen: false);
      
      final searchObject = JobPostingSearchObject(
        Page: reset ? 0 : _currentPage + 1,
        PageSize: _pageSize,
        Title: _searchQuery.isNotEmpty ? _searchQuery : null,
        LocationId: _selectedLocationId,
        SkillIds: _selectedSkills.isNotEmpty ? _selectedSkills.map((s) => s.id).toList() : null,
        experienceLevel: _selectedExperience,
        employmentType: _selectedJobType,
        remote: _selectedRemoteWork,
        IncludeTotalCount: true,
      );
      
      final result = await jobProvider.get(filter: searchObject);
      
      if (result.items != null) {
        await _loadEmployerData(result.items!);
        
        setState(() {
          if (reset) {
            _jobs = result.items!;
            _currentPage = 0;
            _hasMoreData = result.items!.length >= _pageSize;
          } else {
            _jobs.addAll(result.items!);
            _currentPage++;
            _hasMoreData = result.items!.length >= _pageSize;
          }
          _totalCount = result.totalCount ?? _jobs.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading jobs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (!reset && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadEmployerData(List<JobPosting> jobs) async {
    final employerProvider = Provider.of<EmployerProvider>(context, listen: false);
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

  void _onScroll() {
    if (!_isLoading && _hasMoreData) {
      _loadJobs();
    }
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _loadJobs(reset: true);
  }

  void _onFiltersChanged() {
    _loadJobs(reset: true);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedExperience = null;
      _selectedJobType = null;
      _selectedLocationId = null;
      _selectedRemoteWork = null;
      _selectedSkills.clear();
    });
    _onFiltersChanged();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Job Search',
      selectedIndex: 1,
      onScroll: _onScroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilterHeader(),
          if (_showFilters) _buildFiltersPanel(),
          _buildResultsHeader(),
          _buildJobsList(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: AppTheme.primaryColor),
                  onPressed: _onSearch,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalCount jobs found',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  size: 18,
                ),
                label: Text(_showFilters ? 'Hide Filters' : 'Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showFilters ? AppTheme.primaryColor : Colors.white,
                  foregroundColor: _showFilters ? Colors.white : AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter<ExperienceLevel>(
              label: 'Experience Level',
              value: _selectedExperience,
              items: ExperienceLevel.values,
              itemBuilder: (experience) => experienceLevelToString(experience),
              onChanged: (value) {
                setState(() => _selectedExperience = value);
                _onFiltersChanged();
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter<EmploymentType>(
              label: 'Employment Type',
              value: _selectedJobType,
              items: EmploymentType.values,
              itemBuilder: (type) => employmentTypeToString(type),
              onChanged: (value) {
                setState(() => _selectedJobType = value);
                _onFiltersChanged();
              },
            ),
            const SizedBox(height: 16),
            _buildLocationFilter(),
            const SizedBox(height: 16),
            _buildDropdownFilter<Remote>(
              label: 'Remote Work',
              value: _selectedRemoteWork,
              items: Remote.values,
              itemBuilder: (remote) => remoteToString(remote),
              onChanged: (value) {
                setState(() => _selectedRemoteWork = value);
                _onFiltersChanged();
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FormBuilderChips(
                  name: 'skills',
                  allSkills: _allSkills,
                  initialValue: _selectedSkills,
                  searchHint: 'Search skills...',
                  onChanged: (skills) {
                    setState(() => _selectedSkills = skills ?? []);
                    _onFiltersChanged();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    if (_jobs.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Showing ${_jobs.length} of $_totalCount jobs',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: Text('All ${label.toLowerCase()}'),
            items: [
              DropdownMenuItem<T>(
                value: null,
                child: Text('All ${label.toLowerCase()}'),
              ),
              ...items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemBuilder(item)),
                );
              }),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTypeAhead<Location>(
          name: 'location',
          decoration: InputDecoration(
            hintText: 'Search for a location',
            prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          selectionToTextTransformer: (location) => '${location.city}, ${location.country}',
          itemBuilder: (context, location) {
            return ListTile(
              title: Text('${location.city}, ${location.country}'),
            );
          },
          suggestionsCallback: (pattern) async {
            final completer = Completer<List<Location>>();
            
            if (pattern.isEmpty) {
              try {
                final locationProvider = context.read<LocationProvider>();
                final result = await locationProvider.get(filter: LocationSearchObject(RetrieveAll: true));
                if (!completer.isCompleted) {
                  completer.complete(result.items ?? []);
                }
              } catch (e) {
                if (!completer.isCompleted) {
                  completer.complete([]);
                }
              }
            } else {
              _debouncer.run(() async {
                try {
                  final locationProvider = context.read<LocationProvider>();
                  final result = await locationProvider.get(filter: LocationSearchObject(City: pattern));
                  if (!completer.isCompleted) {
                    completer.complete(result.items ?? []);
                  }
                } catch (e) {
                  if (!completer.isCompleted) {
                    completer.complete([]);
                  }
                }
              });
            }
            
            return completer.future;
          },
          onChanged: (location) {
            setState(() => _selectedLocationId = location?.id);
            _onFiltersChanged();
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No locations found'),
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList() {
    if (_isLoading && _jobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _jobs.length + (_hasMoreData && !_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _jobs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final job = _jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            jobId: job.id,
            jobTitle: job.title,
            companyName: job.employerName,
            companyLogoBase64: _employerCache[job.employerId]?.logo,
            location: "${job.locationName} (${switch(job.remote){
                  Remote.yes => 'Remote',
                  Remote.hybrid => 'Hybrid',
                  Remote.no => 'On-site',
                }})",
            employmentType: job.employmentType,
            postedDate: job.postedDate,
            deadlineDate: job.applicationDeadline,
            skills: job.skills.map((s) => s.skillName ?? 'Unknown Skill').toList(),
            isGuest: widget.isGuest,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.jobDetailsRoute,
                arguments: job.id,
              );
            },
          ),
        );
      },
    );
  }
}
