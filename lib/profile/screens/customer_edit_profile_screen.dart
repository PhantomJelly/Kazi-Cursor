import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

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
  final _picker = ImagePicker();
  String? _photoPath;

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
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file != null) setState(() => _photoPath = file.path);
  }

  void _persist() {
    final age = int.tryParse(_ageController.text.trim()) ?? widget.profile.age;
    CustomerProfileStore.instance.updateProfile(
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

  void _save() {
    _persist();
    Navigator.of(context).pop();
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
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _persist();
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: KaziColors.white,
          appBar: AppBar(
            backgroundColor: KaziColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: KaziColors.primary, size: 20),
              onPressed: () {
                _persist();
                Navigator.of(context).pop();
              },
            ),
            title: Text('Edit profile', style: KaziTextStyles.button),
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
                                  child: _photoPath == null
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
                          label: 'Name',
                          hint: 'First name',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _lastNameController,
                          label: 'Surname',
                          hint: 'Last name',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _ageController,
                          label: 'Age',
                          hint: 'e.g. 28',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _townController,
                          label: 'Town',
                          hint: 'e.g. Windhoek',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _countryController,
                          label: 'Country',
                          hint: 'Namibia',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 28),
                        Text('Contact', style: KaziTextStyles.label),
                        const SizedBox(height: 12),
                        KaziTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'you@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          hint: 'e.g. 081 234 5678',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        KaziTextField(
                          controller: _whatsappController,
                          label: 'WhatsApp',
                          hint: 'e.g. 081 234 5678',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: KaziButton(label: 'Save', onPressed: _save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
