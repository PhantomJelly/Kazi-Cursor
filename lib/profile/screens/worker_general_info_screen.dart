import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class WorkerGeneralInfoScreen extends StatefulWidget {
  const WorkerGeneralInfoScreen({super.key, required this.profile});

  final WorkerProfile profile;

  @override
  State<WorkerGeneralInfoScreen> createState() =>
      _WorkerGeneralInfoScreenState();
}

class _WorkerGeneralInfoScreenState extends State<WorkerGeneralInfoScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _townController;
  late final TextEditingController _countryController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _ageController = TextEditingController(
      text: profile.age > 0 ? '${profile.age}' : '',
    );
    _townController = TextEditingController(text: profile.town);
    _countryController = TextEditingController(text: profile.country);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone ?? '');
    _whatsappController = TextEditingController(text: profile.whatsapp ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _townController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    final age = int.tryParse(_ageController.text.trim()) ?? widget.profile.age;
    await WorkerProfileStore.instance.updateGeneralInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: age,
      town: _townController.text.trim(),
      country: _countryController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
    );
  }

  Future<void> _save() async {
    await _persist();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _persist();
          if (context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
        backgroundColor: KaziColors.white,
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(t(context, 'profile.general'), style: KaziTextStyles.button),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KaziTextField(
                        controller: _firstNameController,
                        label: t(context, 'common.name'),
                        hint: t(context, 'common.firstName'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _lastNameController,
                        label: t(context, 'common.surname'),
                        hint: t(context, 'common.lastName'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _ageController,
                        label: t(context, 'common.age'),
                        hint: t(context, 'hint.age'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _townController,
                        label: t(context, 'common.town'),
                        hint: t(context, 'hint.town'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _countryController,
                        label: t(context, 'common.country'),
                        hint: t(context, 'hint.country'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 28),
                      Text(t(context, 'common.contact'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      KaziTextField(
                        controller: _emailController,
                        label: t(context, 'common.email'),
                        hint: t(context, 'hint.emailShort'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _phoneController,
                        label: t(context, 'common.phoneNumber'),
                        hint: t(context, 'hint.phone'),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _whatsappController,
                        label: t(context, 'common.whatsapp'),
                        hint: t(context, 'hint.phone'),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(label: t(context, 'common.save'), onPressed: _save),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
