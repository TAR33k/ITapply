import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/user_insert_request.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/providers/employer_registration_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
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

  String? _logoBase64;
  ImageProvider? _logoPreview;

  final Map<String, dynamic> _formData = {};
  
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxHeight: 600, maxWidth: 600);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoBase64 = base64Encode(bytes);
        _logoPreview = MemoryImage(bytes);
      });
    }
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
           _showErrorFlushbar("Could not verify email. Please try again.");
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
    final allFormValues = _formData;

    final location = allFormValues['location'] as Location?;
    allFormValues['locationId'] = location?.id;

    try {
      int roleId = await context.read<EmployerRegistrationProvider>().getEmployerRoleId();

      final userRequest = UserInsertRequest(
        email: allFormValues['email'],
        password: allFormValues['password'],
        roleIds: [roleId],
      );
      
      allFormValues['logo'] = _logoBase64;

      final rawWebsite = allFormValues['website'] as String;
      if (!rawWebsite.startsWith(RegExp(r'https?://'))) {
        allFormValues['website'] = "https://$rawWebsite";
      }

      await context.read<EmployerRegistrationProvider>().registerEmployer(
            userRequest: userRequest,
            employerData: allFormValues,
          );

      if (mounted) {
        await Flushbar(
          title: "Registration Submitted",
          message: "Your account is pending verification. You will be able to log in once approved.",
          duration: const Duration(seconds: 5),
          backgroundColor: AppTheme.confirmColor,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        ).show(context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorFlushbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorFlushbar(String message) {
     if (mounted) {
        Flushbar(
          title: "Operation Failed",
          message: message.replaceFirst("Exception: ", ""),
          duration: const Duration(seconds: 4),
          backgroundColor: Theme.of(context).colorScheme.error,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        ).show(context);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: AppBar(
        title: const Text("Employer Registration"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: _isLoading ? null : _nextStep,
            onStepCancel: _currentStep == 0 ? null : _previousStep,
            onStepTapped: (int tappedStep) async {
              if (tappedStep == _currentStep) return;

              bool canJump = true;

              for (int i = 0; i < tappedStep; i++) {
                final key = _getFormKeyForStep(i);
                final isValid = key.currentState?.saveAndValidate() ?? false;

                if (!isValid) {
                  canJump = false;
                  break;
                }

                _formData.addAll(key.currentState!.value);
              }

              if (canJump) {
                setState(() => _currentStep = tappedStep);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
                          ),
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('BACK'),
                            ),
                        ],
                      ),
              );
            },
            steps: [
              _buildStep(title: 'Account', content: _buildAccountStep()),
              _buildStep(title: 'Company Profile', content: _buildCompanyProfileStep()),
              _buildStep(title: 'Contact & Location', content: _buildContactStep()),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep({required String title, required Widget content}) {
    int stepIndex = steps.indexOf(title);
    return Step(
      title: Text(title),
      state: _currentStep > stepIndex ? StepState.complete : (_currentStep == stepIndex ? StepState.editing : StepState.indexed),
      isActive: _currentStep >= stepIndex,
      content: content,
    );
  }

  static const List<String> steps = ['Account', 'Company Profile', 'Contact & Location'];

  Widget _buildAccountStep() {
    return FormBuilder(
      key: _step1Key,
      child: Column(children: [
        FormBuilderTextField(
          name: 'email',
          decoration: const InputDecoration(labelText: 'Business Email', prefixIcon: Icon(Icons.email_outlined)),
          validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'password',
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
          validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(8)]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'confirmPassword',
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_person_outlined)),
          validator: (val) => (val != _step1Key.currentState?.fields['password']?.value) ? 'Passwords do not match' : null,
        ),
      ]),
    );
  }

  Widget _buildCompanyProfileStep() {
    return FormBuilder(
      key: _step2Key,
      child: Column(children: [
        FormBuilderTextField(
          name: 'companyName',
          decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business_outlined)),
          validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(200)]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: FormBuilderTextField(
            name: 'industry',
            decoration: const InputDecoration(labelText: 'Industry', prefixIcon: Icon(Icons.factory_outlined)),
            validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(100)]),
          )),
          const SizedBox(width: 16),
          Expanded(child: FormBuilderTextField(
            name: 'yearsInBusiness',
            decoration: const InputDecoration(labelText: 'Years in Business', prefixIcon: Icon(Icons.calendar_today_outlined)),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.integer(errorText: "Must be a whole number."),
              FormBuilderValidators.min(0, errorText: "Cannot be negative."),
              FormBuilderValidators.max(1000, errorText: "Value seems too high."),
            ]),
          )),
        ]),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'size',
          decoration: const InputDecoration(labelText: 'Company Size (e.g., 1-10, 50-100, 200+)', prefixIcon: Icon(Icons.people_outline)),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(50),
            FormBuilderValidators.match(RegExp(r'^\d+(-\d+)?\+?$'), errorText: 'Invalid format. Use "10", "1-10", or "10+".'),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'description',
          decoration: const InputDecoration(labelText: 'Company Description', border: OutlineInputBorder()),
          maxLines: 4,
          validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(5000)]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'benefits',
          decoration: const InputDecoration(labelText: 'Employee Benefits', border: OutlineInputBorder()),
          maxLines: 3,
          validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(3000)]),
        ),
      ]),
    );
  }

  Widget _buildContactStep() {
    return FormBuilder(
      key: _step3Key,
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: Column(children: [
            FormBuilderTextField(
              name: 'address',
              decoration: const InputDecoration(labelText: 'Company Address', prefixIcon: Icon(Icons.location_on_outlined)),
              validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(500)]),
            ),
            const SizedBox(height: 16),
            FormBuilderTypeAhead<Location>(
              name: 'location',
              decoration: const InputDecoration(labelText: 'Primary Location', prefixIcon: Icon(Icons.location_city_outlined)),
              validator: FormBuilderValidators.required(errorText: "Location is required."),
              itemBuilder: (context, location) {
                return ListTile(
                  title: Text(location.city),
                  subtitle: Text(location.country),
                );
              },
              suggestionsCallback: (pattern) async {
                Completer<List<Location>> completer = Completer();
                if (pattern.isEmpty) {
                  try {
                      final locationProvider = context.read<LocationProvider>();
                      final result = await locationProvider.get(filter: LocationSearchObject(RetrieveAll: true));
                      if (!completer.isCompleted) {
                         completer.complete(result.items);
                      }
                   } catch (e) {
                      if (!completer.isCompleted) {
                         completer.completeError(e);
                      }
                   }
                }
                _debouncer.run(() async {
                   try {
                      final locationProvider = context.read<LocationProvider>();
                      final result = await locationProvider.get(filter: LocationSearchObject(City: pattern));
                      if (!completer.isCompleted) {
                         completer.complete(result.items);
                      }
                   } catch (e) {
                      if (!completer.isCompleted) {
                         completer.completeError(e);
                      }
                   }
                });
                return completer.future;
              },
              onSelected: (Location suggestion) {
                final formState = _getFormKeyForStep(_currentStep).currentState!;
                formState.fields['location']?.didChange(suggestion);
              },
              selectionToTextTransformer: (Location suggestion) => "${suggestion.city}, ${suggestion.country}",
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'website',
              decoration: const InputDecoration(
                labelText: 'Website URL',
                prefixIcon: Icon(Icons.public_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.match(
                  RegExp(r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$'),
                  errorText: "Enter a valid website URL (e.g., https://example.com)",
                ),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'contactEmail',
              decoration: const InputDecoration(labelText: 'Public Contact Email', prefixIcon: Icon(Icons.alternate_email)),
              validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'contactPhone',
              decoration: const InputDecoration(
                labelText: 'Public Contact Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.match(
                  RegExp(r'^\+?[0-9]{1,3}?[-.\s]?(\(?\d{1,4}?\)?)[-.\s]?\d{1,4}[-.\s]?\d{1,9}$'),
                  errorText: 'Invalid phone number format.',
                ),
              ]),
            ),
          ])),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: Column(children: [
            const Text("Company Logo"),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.grayColor),
                  borderRadius: BorderRadius.circular(8),
                  image: _logoPreview != null ? DecorationImage(image: _logoPreview!, fit: BoxFit.cover) : null,
                ),
                child: _logoPreview == null ? const Center(child: Icon(Icons.add_a_photo_outlined, color: AppTheme.secondaryColor, size: 40)) : null,
              ),
            )
          ])),
        ]),
      ]),
    );
  }
}