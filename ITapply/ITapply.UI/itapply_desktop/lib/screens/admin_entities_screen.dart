import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/location_insert_request.dart';
import 'package:itapply_desktop/models/requests/location_update_request.dart';
import 'package:itapply_desktop/models/requests/role_insert_request.dart';
import 'package:itapply_desktop/models/requests/role_update_request.dart';
import 'package:itapply_desktop/models/requests/skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/skill_update_request.dart';
import 'package:itapply_desktop/models/role.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/role_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/role_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AdminEntitiesScreen extends StatefulWidget {
  const AdminEntitiesScreen({super.key});

  @override
  State<AdminEntitiesScreen> createState() => _AdminEntitiesScreenState();
}

class _AdminEntitiesScreenState extends State<AdminEntitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Skill> _skills = [];
  List<Location> _locations = [];
  List<Role> _roles = [];
  
  List<Skill> _filteredSkills = [];
  List<Location> _filteredLocations = [];
  List<Role> _filteredRoles = [];
  
  final TextEditingController _skillsSearchController = TextEditingController();
  final TextEditingController _locationsSearchController = TextEditingController();
  final TextEditingController _rolesSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _skillsSearchController.dispose();
    _locationsSearchController.dispose();
    _rolesSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        context.read<SkillProvider>().get(filter: SkillSearchObject(RetrieveAll: true)),
        context.read<LocationProvider>().get(filter: LocationSearchObject(RetrieveAll: true)),
        context.read<RoleProvider>().get(filter: RoleSearchObject(RetrieveAll: true)),
      ]);

      if (mounted) {
        setState(() {
          _skills = results[0].items as List<Skill>;
          _locations = results[1].items as List<Location>;
          _roles = results[2].items as List<Role>;
          _error = null;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Failed to load data: ${e.toString().replaceFirst("Exception: ", "")}");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final skillsQuery = _skillsSearchController.text.toLowerCase();
    final locationsQuery = _locationsSearchController.text.toLowerCase();
    final rolesQuery = _rolesSearchController.text.toLowerCase();
    
    _filteredSkills = _skills.where((skill) {
      return skill.name.toLowerCase().contains(skillsQuery);
    }).toList();
    
    _filteredLocations = _locations.where((location) {
      return location.city.toLowerCase().contains(locationsQuery) ||
             location.country.toLowerCase().contains(locationsQuery);
    }).toList();
    
    _filteredRoles = _roles.where((role) {
      return role.name.toLowerCase().contains(rolesQuery);
    }).toList();
  }

  void _performSearch() {
    setState(() {
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Platform Entities Management",
      selectedRoute: AppRouter.adminEntitiesRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.lightbulb_outline), text: "Skills"),
                        Tab(icon: Icon(Icons.location_on_outlined), text: "Locations"),
                        Tab(icon: Icon(Icons.security_outlined), text: "Roles"),
                      ],
                    ),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 800,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSkillsTab(),
                          _buildLocationsTab(),
                          _buildRolesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSkillsTab() {
    return _buildCrudSection<Skill>(
      title: "Manage Skills",
      data: _filteredSkills,
      searchController: _skillsSearchController,
      onSearch: _performSearch,
      searchHint: "Search skills...",
      itemBuilder: (skill) => ListTile(
        leading: const Icon(Icons.code),
        title: Text(skill.name),
      ),
      onAdd: () => _showSkillDialog(),
      onEdit: (skill) => _showSkillDialog(skill: skill),
      onDelete: (skill) async {
        await context.read<SkillProvider>().delete(skill.id);
      },
    );
  }

  Widget _buildLocationsTab() {
    return _buildCrudSection<Location>(
      title: "Manage Locations",
      data: _filteredLocations,
      searchController: _locationsSearchController,
      onSearch: _performSearch,
      searchHint: "Search locations...",
      itemBuilder: (location) => ListTile(
        leading: const Icon(Icons.map_outlined),
        title: Text(location.city),
        subtitle: Text(location.country),
      ),
      onAdd: () => _showLocationDialog(),
      onEdit: (location) => _showLocationDialog(location: location),
      onDelete: (location) async {
        await context.read<LocationProvider>().delete(location.id);
      },
    );
  }

  Widget _buildRolesTab() {
    return _buildCrudSection<Role>(
      title: "Manage User Roles",
      data: _filteredRoles,
      searchController: _rolesSearchController,
      onSearch: _performSearch,
      searchHint: "Search roles...",
      itemBuilder: (role) => ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(role.name),
      ),
      onAdd: () => _showRoleDialog(),
      onEdit: (role) => _showRoleDialog(role: role),
      onDelete: (role) async {
        await context.read<RoleProvider>().delete(role.id);
      },
    );
  }

  Widget _buildCrudSection<T>({
    required String title,
    required List<T> data,
    required Widget Function(T item) itemBuilder,
    required VoidCallback onAdd,
    required Function(T item) onEdit,
    required Future<void> Function(T item) onDelete,
    TextEditingController? searchController,
    VoidCallback? onSearch,
    String? searchHint,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text("Add New"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (searchController != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: searchHint ?? "Search...",
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => onSearch?.call(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onSearch,
                    child: const Text('Search'),
                  ),
                ],
              ),
            if (searchController != null) const SizedBox(height: 16),
            data.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "No items found.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Click 'Add New' to create the first item.",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: itemBuilder(item)),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => onEdit(item),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await _showConfirmDialog(
                                      "Delete Item?", "Are you sure? This action cannot be undone.");
                                  if (confirmed == true) {
                                    try {
                                      await onDelete(item);
                                      _showFeedback("Item deleted successfully.");
                                      await _fetchData();
                                    } catch (e) {
                                      _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
                                    }
                                  }
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                  ),
          ],
        ),
      ),
    );
  }

  void _showSkillDialog({Skill? skill}) {
    _showEntityDialog(
      title: skill == null ? "Add New Skill" : "Edit Skill",
      initialValue: skill == null ? {} : {'name': skill.name},
      formFields: [
        FormBuilderTextField(
          name: 'name',
          decoration: const InputDecoration(labelText: 'Skill Name'),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(100),
          ]),
        ),
      ],
      onSave: (value) async {
        if (skill == null) {
          final request = SkillInsertRequest(name: value['name']);
          await context.read<SkillProvider>().insert(request);
        } else {
          final request = SkillUpdateRequest(name: value['name']);
          await context.read<SkillProvider>().update(skill.id, request);
        }
      },
    );
  }

  void _showLocationDialog({Location? location}) {
    _showEntityDialog(
      title: location == null ? "Add New Location" : "Edit Location",
      initialValue: location == null ? {} : {'city': location.city, 'country': location.country},
      formFields: [
        FormBuilderTextField(
          name: 'city',
          decoration: const InputDecoration(labelText: 'City'),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(100),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'country',
          decoration: const InputDecoration(labelText: 'Country'),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(100),
          ]),
        ),
      ],
      onSave: (value) async {
        if (location == null) {
          final request = LocationInsertRequest(city: value['city'], country: value['country']);
          await context.read<LocationProvider>().insert(request);
        } else {
          final request = LocationUpdateRequest(city: value['city'], country: value['country']);
          await context.read<LocationProvider>().update(location.id, request);
        }
      },
    );
  }

  void _showRoleDialog({Role? role}) {
    _showEntityDialog(
      title: role == null ? "Add New Role" : "Edit Role",
      initialValue: role == null ? {} : {'name': role.name},
      formFields: [
        FormBuilderTextField(
          name: 'name',
          decoration: const InputDecoration(labelText: 'Role Name'),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(50),
          ]),
        ),
      ],
      onSave: (value) async {
        if (role == null) {
          final request = RoleInsertRequest(name: value['name']);
          await context.read<RoleProvider>().insert(request);
        } else {
          final request = RoleUpdateRequest(name: value['name']);
          await context.read<RoleProvider>().update(role.id, request);
        }
      },
    );
  }
  
  Future<void> _showEntityDialog({
    required String title,
    required List<Widget> formFields,
    required Map<String, dynamic> initialValue,
    required Future<void> Function(Map<String, dynamic> value) onSave,
  }) async {
    final formKey = GlobalKey<FormBuilderState>();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: FormBuilder(
          key: formKey,
          initialValue: initialValue,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formFields,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                try {
                  await onSave(formKey.currentState!.value);
                  Navigator.of(context).pop();
                  _showFeedback("Saved successfully.");
                  await _fetchData();
                } catch (e) {
                  _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
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
}