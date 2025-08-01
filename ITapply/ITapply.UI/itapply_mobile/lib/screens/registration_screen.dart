import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/location.dart';
import 'package:itapply_mobile/models/requests/user_insert_request.dart';
import 'package:itapply_mobile/models/search_objects/location_search_object.dart';
import 'package:itapply_mobile/providers/candidate_registration_provider.dart';
import 'package:itapply_mobile/providers/location_provider.dart';
import 'package:itapply_mobile/providers/user_provider.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

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

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _step1Key = GlobalKey<FormBuilderState>();
  final _step2Key = GlobalKey<FormBuilderState>();
  final _step3Key = GlobalKey<FormBuilderState>();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final Map<String, dynamic> _formData = {};
  final _debouncer = Debouncer(milliseconds: 500);

  final List<String> _stepTitles = [
    'Account Details',
    'Personal Information',
    'Professional Details'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppTheme.darkColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            _stepTitles[_currentStep],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < 2 ? 8 : 0,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor : AppTheme.grayColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of 3',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildProfessionalStep();
      default:
        return _buildAccountStep();
    }
  }

  Widget _buildAccountStep() {
    return FormBuilder(
      key: _step1Key,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s start with your account credentials',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email is required'),
              FormBuilderValidators.email(errorText: 'Enter a valid email address'),
              (value) {
                if (value != null && (!value.contains('@') || !value.contains('.'))) {
                  return 'Email must contain @ and . characters';
                }
                return null;
              },
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: !_passwordVisible,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Password is required'),
              FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: !_confirmPasswordVisible,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Please confirm your password'),
              (value) {
                final password = _step1Key.currentState?.fields['password']?.value;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return FormBuilder(
      key: _step2Key,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'firstName',
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'First name is required'),
                    FormBuilderValidators.minLength(2, errorText: 'First name must be at least 2 characters'),
                    FormBuilderValidators.maxLength(50, errorText: 'First name cannot exceed 50 characters'),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderTextField(
                  name: 'lastName',
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Last name is required'),
                    FormBuilderValidators.minLength(2, errorText: 'Last name must be at least 2 characters'),
                    FormBuilderValidators.maxLength(50, errorText: 'Last name cannot exceed 50 characters'),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'phoneNumber',
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.phone,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Phone number is required'),
              FormBuilderValidators.match(
                RegExp(r'^\+?[0-9]{1,3}?[-.\s]?(\(?\d{1,4}?\)?)[-.\s]?\d{1,4}[-.\s]?\d{1,9}$'),
                errorText: 'Enter a valid phone number',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTypeAhead<Location>(
            name: 'location',
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'Search for your city',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormBuilderValidators.required(errorText: 'Location is required'),
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
            onSelected: (Location suggestion) {
              final formState = _step2Key.currentState!;
              formState.fields['location']?.didChange(suggestion);
            },
            selectionToTextTransformer: (Location suggestion) => "${suggestion.city}, ${suggestion.country}",
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalStep() {
    return FormBuilder(
      key: _step3Key,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional background',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'title',
            decoration: InputDecoration(
              labelText: 'Professional Title',
              hintText: 'e.g., Senior Full Stack Developer',
              prefixIcon: const Icon(Icons.work_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Professional title is required'),
              FormBuilderValidators.minLength(3, errorText: 'Title must be at least 3 characters'),
              FormBuilderValidators.maxLength(100, errorText: 'Title cannot exceed 100 characters'),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'experienceYears',
            decoration: InputDecoration(
              labelText: 'Years of Experience',
              hintText: 'Enter years of experience',
              prefixIcon: const Icon(Icons.timeline_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Experience years is required'),
              FormBuilderValidators.numeric(errorText: 'Enter a valid number'),
              FormBuilderValidators.min(0, errorText: 'Experience cannot be negative'),
              FormBuilderValidators.max(100, errorText: 'Experience cannot exceed 100 years'),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderDropdown<ExperienceLevel>(
            name: 'experienceLevel',
            decoration: InputDecoration(
              labelText: 'Experience Level',
              prefixIcon: const Icon(Icons.trending_up_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormBuilderValidators.required(errorText: 'Experience level is required'),
            items: ExperienceLevel.values.map((level) {
              String displayName = experienceLevelToString(level);
              return DropdownMenuItem(
                value: level,
                child: Text(displayName),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'bio',
            decoration: InputDecoration(
              labelText: 'Professional Bio',
              hintText: 'Tell us about your experience and skills...',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.maxLength(1000, errorText: 'Bio cannot exceed 1000 characters', checkNullOrEmpty: false),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppTheme.grayColor),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Create Account' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _nextStep() async {
    final currentFormKey = _getFormKeyForStep(_currentStep);
    
    if (currentFormKey.currentState?.saveAndValidate() ?? false) {
      if (_currentStep == 0) {
        setState(() => _isLoading = true);
        try {
          final email = currentFormKey.currentState!.value['email'];
          final emailExists = await context.read<UserProvider>().checkEmailExists(email);
          if (mounted && emailExists) {
            currentFormKey.currentState!.fields['email']?.invalidate('This email is already taken.');
            return;
          }
        } catch (e) {
          _showErrorDialog("Could not verify email. Please check your connection and try again.");
          return;
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }

      _formData.addAll(currentFormKey.currentState!.value);

      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        await _submitRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  GlobalKey<FormBuilderState> _getFormKeyForStep(int step) {
    switch (step) {
      case 0: return _step1Key;
      case 1: return _step2Key;
      case 2: return _step3Key;
      default: return _step1Key;
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    
    try {
      final allFormValues = _formData;
      final location = allFormValues['location'] as Location?;
      
      int roleId = await context.read<CandidateRegistrationProvider>().getCandidateRoleId();

      final userRequest = UserInsertRequest(
        email: allFormValues['email'],
        password: allFormValues['password'],
        roleIds: [roleId],
      );

      final candidateData = {
        'firstName': allFormValues['firstName'],
        'lastName': allFormValues['lastName'],
        'phoneNumber': allFormValues['phoneNumber'],
        'title': allFormValues['title'],
        'bio': allFormValues['bio'],
        'locationId': location?.id,
        'experienceYears': int.tryParse(allFormValues['experienceYears'].toString()) ?? 0,
        'experienceLevel': allFormValues['experienceLevel'] as ExperienceLevel?,
      };

      await context.read<CandidateRegistrationProvider>().registerCandidate(
        userRequest: userRequest,
        candidateData: candidateData,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            const Text('Registration Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.confirmColor),
            const SizedBox(width: 8),
            const Text('Success!'),
          ],
        ),
        content: const Text(
          'Your account has been created successfully! You can now log in with your credentials.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}
