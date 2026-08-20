import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/profile/widgets/specialization_selector.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/photo_picker.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/supabase/media_storage.dart';

class WorkerWorkHistoryScreen extends StatefulWidget {
  const WorkerWorkHistoryScreen({super.key});

  @override
  State<WorkerWorkHistoryScreen> createState() =>
      _WorkerWorkHistoryScreenState();
}

class _WorkerWorkHistoryScreenState extends State<WorkerWorkHistoryScreen> {
  List<TradeCategory> _selected = [];
  WorkExperienceLevel? _experience;
  String? _photoPath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final profile = WorkerProfileStore.instance.profile;
    if (profile != null) {
      _selected = List.of(profile.specializations);
      _experience = profile.experience;
      _photoPath = profile.profilePhotoPath;
    }
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
    await WorkerProfileStore.instance.updateWorkHistory(
      specializations: _selected,
      experience: _experience,
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
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(t(context, 'profile.workHistory'), style: KaziTextStyles.button),
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
                      SpecializationSelector(
                        selected: _selected,
                        onChanged: (value) =>
                            setState(() => _selected = value),
                      ),
                      const SizedBox(height: 28),
                      Text(t(context, 'profile.experience'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      ...WorkExperienceLevel.values.map((level) {
                        final isSelected = _experience == level;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _experience = level),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? KaziColors.primaryTint
                                    : KaziColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? KaziColors.primary
                                      : KaziColors.grey15,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                level.label,
                                style: KaziTextStyles.input.copyWith(
                                  color: isSelected
                                      ? KaziColors.primary
                                      : KaziColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                      Text(t(context, 'profile.photo'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: KaziColors.grey8,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: KaziColors.grey15,
                              width: 1.5,
                            ),
                            image: _photoPath != null && !_isUploading
                                ? DecorationImage(
                                    image: platform_image
                                        .imageProviderFromPath(_photoPath!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: KaziColors.primary,
                                  ),
                                )
                              : _photoPath == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.camera_alt_outlined,
                                            color: KaziColors.grey, size: 32),
                                        const SizedBox(height: 8),
                                        Text(
                                          t(context, 'profile.takeOrChoose'),
                                          style: KaziTextStyles.subtitle
                                              .copyWith(fontSize: 14),
                                        ),
                                      ],
                                    )
                                  : null,
                        ),
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
