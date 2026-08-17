import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/authentication/widgets/role_selector.dart';
import 'package:kazi/app_shell/customer_app_shell.dart';
import 'package:kazi/app_shell/worker_app_shell.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class SignUpProfileScreen extends StatefulWidget {
  const SignUpProfileScreen({
    super.key,
    required this.signUpData,
  });

  final SignUpData signUpData;

  @override
  State<SignUpProfileScreen> createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _townController = TextEditingController();
  final _countryController = TextEditingController(text: 'Namibia');
  UserRole? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _townController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _townController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 16 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age (16–100)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Worker or Customer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _completeSignUp() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final data = widget.signUpData.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      town: _townController.text.trim(),
      country: _countryController.text.trim(),
      role: _selectedRole,
    );

    // TODO(backend): POST /auth/register with data
    if (data.role == UserRole.worker) {
      WorkerProfileStore.instance.initFromSignUp(data);
    } else {
      CustomerProfileStore.instance.initFromSignUp(data);
    }

    final created = await LocalAccountStore.instance.register(data);
    if (!mounted) return;
    if (!created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An account with these details already exists.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (data.role == UserRole.worker) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WorkerAppShell()),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const CustomerAppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: KaziColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Tell us about you', style: KaziTextStyles.heading),
                      const SizedBox(height: 12),
                      Text(
                        'This helps us connect you with the right work.',
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      KaziTextField(
                        controller: _firstNameController,
                        label: 'Name',
                        hint: 'First name',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _lastNameController,
                        label: 'Surname',
                        hint: 'Last name',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'e.g. 25',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _townController,
                        label: 'Town',
                        hint: 'e.g. Windhoek',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'e.g. Namibia',
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 28),
                      RoleSelector(
                        selectedRole: _selectedRole,
                        onRoleSelected: (role) {
                          setState(() => _selectedRole = role);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(
                  label: 'Create account',
                  isLoading: _isLoading,
                  onPressed: _completeSignUp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
