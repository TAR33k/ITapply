import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/models/search_objects/skill_search_object.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/employer_skill.dart';
import 'package:itapply_mobile/models/skill.dart';
import 'package:itapply_mobile/models/location.dart';
import 'package:itapply_mobile/models/search_objects/employer_search_object.dart';
import 'package:itapply_mobile/models/search_objects/employer_skill_search_object.dart';
import 'package:itapply_mobile/models/search_objects/location_search_object.dart';
import 'package:itapply_mobile/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/employer_skill_provider.dart';
import 'package:itapply_mobile/providers/skill_provider.dart';
import 'package:itapply_mobile/providers/location_provider.dart';
import 'package:itapply_mobile/providers/review_provider.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/widgets/employer_card.dart';
import 'package:itapply_mobile/widgets/form_builder_chips.dart';

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

class EmployerListScreen extends StatefulWidget {
  final bool isGuest;
  final String? initialSearchQuery;
  final Map<String, dynamic>? initialFilters;

  const EmployerListScreen({
    super.key,
    this.isGuest = false,
    this.initialSearchQuery,
    this.initialFilters,
  });

  @override
  State<EmployerListScreen> createState() => _EmployerListScreenState();
}

class _EmployerListScreenState extends State<EmployerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  
  bool _showFilters = false;
  List<Employer> _employers = [];
  List<Skill> _allSkills = [];
  
  String _searchQuery = '';
  int? _selectedLocationId;
  List<Skill> _selectedSkills = [];
  
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMoreData = true;
  int _totalCount = 0;

  bool _isLoading = false;
  
  // ignore: prefer_final_fields
  Map<int, List<EmployerSkill>> _employerSkillsCache = {};
  // ignore: prefer_final_fields
  Map<int, double> _employerRatingsCache = {};
  // ignore: prefer_final_fields
  Map<int, int> _employerReviewCountsCache = {};
  // ignore: prefer_final_fields
  Map<int, int> _employerJobCountsCache = {};

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
      await _loadEmployers(reset: true);
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

  Future<void> _loadEmployers({bool reset = false}) async {
    if (!reset && (_isLoading || !_hasMoreData)) return;
    
    if (!reset) {
      setState(() => _isLoading = true);
    }
    
    try {
      final employerProvider = Provider.of<EmployerProvider>(context, listen: false);
      
      final searchObject = EmployerSearchObject(
        Page: reset ? 0 : _currentPage + 1,
        PageSize: _pageSize,
        CompanyName: _searchQuery.isNotEmpty ? _searchQuery : null,
        LocationId: _selectedLocationId,
        verificationStatus: VerificationStatus.approved,
        IsActive: true,
        IncludeTotalCount: true,
      );
      
      final result = await employerProvider.get(filter: searchObject);
      
      if (result.items != null) {
        List<Employer> filteredEmployers = result.items!;
        
        if (_selectedSkills.isNotEmpty) {
          filteredEmployers = await _filterEmployersBySkills(result.items!);
        }
        
        await _loadEmployerAdditionalData(filteredEmployers);
        
        setState(() {
          if (reset) {
            _employers = filteredEmployers;
            _currentPage = 0;
            _hasMoreData = result.items!.length >= _pageSize;

            if (_selectedSkills.isNotEmpty) {
              _totalCount = filteredEmployers.length;
            } else {
              _totalCount = result.totalCount ?? _employers.length;
            }
          } else {
            _employers.addAll(filteredEmployers);
            _currentPage++;
            _hasMoreData = result.items!.length >= _pageSize;
            
            if (_selectedSkills.isNotEmpty) {
              _totalCount = _employers.length;
            } else {
              _totalCount = result.totalCount ?? _employers.length;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading employers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employers: ${e.toString()}'),
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

  Future<void> _loadEmployerAdditionalData(List<Employer> employers) async {
    final employerSkillProvider = Provider.of<EmployerSkillProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final jobPostingProvider = Provider.of<JobPostingProvider>(context, listen: false);

    for (final employer in employers) {
      if (!_employerSkillsCache.containsKey(employer.id)) {
        try {
          final skillsResult = await employerSkillProvider.get(filter: EmployerSkillSearchObject(EmployerId: employer.id));
          _employerSkillsCache[employer.id] = skillsResult.items ?? [];

          try {
            final allReviews = await reviewProvider.getByEmployerId(employer.id);
            final approvedReviews = allReviews.where((review) => review.moderationStatus == ModerationStatus.approved).toList();
            _employerReviewCountsCache[employer.id] = approvedReviews.length;
            
            if (approvedReviews.isNotEmpty) {
              try {
                final rating = await reviewProvider.getAverageRatingForEmployer(employer.id);
                _employerRatingsCache[employer.id] = rating;
              } catch (e) {
                _employerRatingsCache[employer.id] = approvedReviews.map((r) => r.rating).reduce((a, b) => a + b) / approvedReviews.length;
              }
            } else {
              _employerRatingsCache[employer.id] = 0.0;
            }
          } catch (e) {
            _employerReviewCountsCache[employer.id] = 0;
            _employerRatingsCache[employer.id] = 0.0;
          }

          try {
            final jobsResult = await jobPostingProvider.get(filter: JobPostingSearchObject(
              EmployerId: employer.id,
              Status: JobPostingStatus.active,
              RetrieveAll: true,
              IncludeTotalCount: true,
            ));
            _employerJobCountsCache[employer.id] = jobsResult.totalCount ?? 0;
          } catch (e) {
            _employerJobCountsCache[employer.id] = 0;
          }
        } catch (e) {
          debugPrint('Error loading additional data for employer ${employer.id}: $e');
        }
      }
    }
  }

  void _onScroll() {
    if (!_isLoading && _hasMoreData) {
      _loadEmployers();
    }
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _loadEmployers(reset: true);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedLocationId = null;
      _selectedSkills.clear();
    });
    _loadEmployers(reset: true);
  }

  void _onFiltersChanged() {
    _loadEmployers(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Companies',
      selectedIndex: 2,
      onScroll: _onScroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(),
          if (_showFilters) _buildFiltersPanel(),
          _buildEmployerList(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
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
                hintText: 'Search companies...',
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
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 260) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      '$_totalCount companies found',
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
                    )
                  ]
                );
              }
              else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_totalCount companies found',
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
                    )
                  ]
                );
              }
            }
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
            _buildLocationFilter(),
            const SizedBox(height: 16),
            _buildSkillsFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTypeAhead<Location>(
          name: 'location',
          decoration: InputDecoration(
            hintText: 'Search for location...',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
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
            setState(() {
              _selectedLocationId = location?.id;
            });
            _onFiltersChanged();
          },
          selectionToTextTransformer: (location) => '${location.city}, ${location.country}',
        ),
      ],
    );
  }

  Widget _buildSkillsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderChips(
          name: 'skills',
          allSkills: _allSkills,
          initialValue: _selectedSkills,
          onChanged: (selectedSkills) {
            setState(() {
              _selectedSkills = selectedSkills ?? [];
            });
            _onFiltersChanged();
          },
        ),
      ],
    );
  }

  Widget _buildEmployerList() {
    if (_isLoading && _employers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_employers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No companies found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
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
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _employers.length + (_hasMoreData && !_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _employers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final employer = _employers[index];
        final skills = _employerSkillsCache[employer.id] ?? [];
        final rating = _employerRatingsCache[employer.id];
        final reviewCount = _employerReviewCountsCache[employer.id] ?? 0;
        final jobCount = _employerJobCountsCache[employer.id] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EmployerCard(
            employer: employer,
            skills: skills,
            averageRating: rating ?? 0.0,
            reviewCount: reviewCount,
            activeJobCount: jobCount,
            isGuest: widget.isGuest,
            onTap: () async {
              final employerId = employer.id;
              final companyName = employer.companyName;
              final isGuest = widget.isGuest;
              var result = await Navigator.pushNamed(
                context,
                AppRouter.employerDetailsRoute,
                arguments: {'employerId': employerId, 'companyName': companyName, 'isGuest': isGuest},
              );
              if (result == true) {
                setState(() {
                  _employerRatingsCache.clear();
                  _employerReviewCountsCache.clear();
                  _employerSkillsCache.clear();
                  _employerJobCountsCache.clear();
                  _loadEmployers();
                });
              }
            },
          ),
        );
      },
    );
  }

  Future<List<Employer>> _filterEmployersBySkills(List<Employer> employers) async {
    if (_selectedSkills.isEmpty) return employers;
    
    final employerSkillProvider = Provider.of<EmployerSkillProvider>(context, listen: false);
    List<Employer> filteredEmployers = [];
    
    for (final employer in employers) {
      try {
        final skillsResult = await employerSkillProvider.get(filter: EmployerSkillSearchObject(EmployerId: employer.id));
        final employerSkills = skillsResult.items ?? [];
        
        final hasSelectedSkill = _selectedSkills.any((selectedSkill) => 
          employerSkills.any((employerSkill) => employerSkill.skillId == selectedSkill.id)
        );
        
        if (hasSelectedSkill) {
          filteredEmployers.add(employer);
        }
      } catch (e) {
        debugPrint('Error filtering employer ${employer.id} by skills: $e');
        filteredEmployers.add(employer);
      }
    }
    
    return filteredEmployers;
  }
}
