import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/screens/awaiting_approval_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final rememberedEmail = prefs.getString('rememberedEmail');
    setState(() {
      _rememberMe = rememberedEmail != null;
      if (_rememberMe) {
        _emailController.text = rememberedEmail!;
      }
    });
  }

  Future<void> _handleRememberMe(bool value) async {
    setState(() => _rememberMe = value);
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('rememberedEmail', _emailController.text);
    } else {
      await prefs.remove('rememberedEmail');
    }
  }

  Future<void> _login() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rememberedEmail', _emailController.text);
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.login(
              _emailController.text.trim(),
              _passwordController.text,
            );
            
        if (mounted) {
          final employer = authProvider.currentEmployer;
          if (employer != null) {
            if (employer.verificationStatus == VerificationStatus.approved) {
              Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => AwaitingApprovalScreen(employer: employer)
              ));
            }
          } else {
            Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.toString().replaceFirst("Exception: ", ""));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useTwoPanelLayout = constraints.maxWidth >= 950;
            return Row(
              children: [
                if (useTwoPanelLayout) _buildBrandingPanel(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48.0, vertical: 24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandingPanel() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryDarkColor, AppTheme.primaryColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                "ITapply Desktop",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Connecting IT Talent with Opportunity.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Welcome", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            "Sign in or create an account to continue.",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.secondaryColor),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
                labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) =>
                (v == null || v.isEmpty || !v.contains('@')) ? 'Please enter a valid email' : null,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocusNode),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.secondaryColor),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter your password' : null,
            onFieldSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => _handleRememberMe(v ?? false)),
                  const Text("Remember Email"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20)),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white))
                : const Text('SIGN IN'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushNamed(context, AppRouter.registrationRoute);
                  },
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20)),
            child: const Text('REGISTER'),
          ),
          const SizedBox(height: 40),
          Text(
            "© ${DateTime.now().year} ITapply. All rights reserved.",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.secondaryColor),
          ),
        ],
      ),
    );
  }
}