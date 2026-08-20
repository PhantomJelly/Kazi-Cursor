import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/photo_picker.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';
import 'package:kazi/supabase/media_storage.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key, required this.profile});

  final CustomerProfile profile;

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _townController;
  late final TextEditingController _countryController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  String? _photoPath;
  bool _isUploading = false;

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
    _photoPath = profile.profilePhotoPath;
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

  Future<void> _pickPhoto() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);
    final url = await PhotoPicker.pickAndUpload(
      context,
      bucket: MediaStorage.avatars,
    );
    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (url != null) _photoPath = url;
    });
  }

  Future<void> _persist() async {
    final age = int.tryParse(_ageController.text.trim()) ?? widget.profile.age;
    await CustomerProfileStore.instance.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: age,
      town: _townController.text.trim(),
      country: _countryController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      profilePhotoPath: _photoPath,
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
              onPressed: () async {
                await _persist();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            title: Text(t(context, 'common.editProfile'), style: KaziTextStyles.button),
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
                        Center(
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: KaziColors.grey8,
                                  backgroundImage: _photoPath != null
                                      ? platform_image
                                          .imageProviderFromPath(_photoPath!)
                                      : null,
                                  child: _isUploading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: KaziColors.primary,
                                          ),
                                        )
                                      : _photoPath == null
                                          ? const Icon(
                                              Icons.person_outline,
                                              color: KaziColors.grey,
                                              size: 40,
                                            )
                                          : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: KaziColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: KaziColors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
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
