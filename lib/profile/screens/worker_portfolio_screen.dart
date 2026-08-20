import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/photo_picker.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/supabase/media_storage.dart';

class WorkerPortfolioScreen extends StatefulWidget {
  const WorkerPortfolioScreen({super.key});

  @override
  State<WorkerPortfolioScreen> createState() => _WorkerPortfolioScreenState();
}

class _WorkerPortfolioScreenState extends State<WorkerPortfolioScreen> {
  final _bioController = TextEditingController();
  List<String> _photoPaths = [];
  bool _isUploading = false;

  int get _wordCount => _bioController.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;

  @override
  void initState() {
    super.initState();
    final profile = WorkerProfileStore.instance.profile;
    if (profile != null) {
      _bioController.text = profile.bio;
      _photoPaths = List.of(profile.portfolioPhotoPaths);
    }
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);
    final urls = await PhotoPicker.pickManyAndUpload(
      context,
      bucket: MediaStorage.portfolio,
    );
    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (urls.isNotEmpty) {
        _photoPaths = [..._photoPaths, ...urls];
      }
    });
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  Future<void> _persist() async {
    await WorkerProfileStore.instance.updatePortfolio(
      bio: _bioController.text.trim(),
      portfolioPhotoPaths: _photoPaths,
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
          title: Text(t(context, 'profile.portfolio'), style: KaziTextStyles.button),
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
                      Text(t(context, 'profile.bio'), style: KaziTextStyles.label),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'profile.bioHint', {
                          'min': '${WorkerProfile.bioMinWords}',
                        }),
                        style: KaziTextStyles.subtitle.copyWith(
                          fontSize: 13,
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioController,
                        maxLines: 8,
                        style: KaziTextStyles.input,
                        decoration: InputDecoration(
                          hintText: t(context, 'profile.bioExample'),
                          hintStyle: KaziTextStyles.input
                              .copyWith(color: KaziColors.textHint),
                          filled: true,
                          fillColor: KaziColors.white,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: KaziColors.grey15,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: KaziColors.grey15,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: KaziColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t(context, 'profile.wordCount', {
                          'count': '$_wordCount',
                          'min': '${WorkerProfile.bioMinWords}',
                        }),
                        style: KaziTextStyles.subtitle.copyWith(
                          fontSize: 13,
                          color: _wordCount >= WorkerProfile.bioMinWords
                              ? KaziColors.primary
                              : KaziColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t(context, 'profile.jobPhotos'), style: KaziTextStyles.label),
                          Text(
                            t(context, 'profile.optional'),
                            style: KaziTextStyles.subtitle.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _addPhotos,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: KaziColors.grey8,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: KaziColors.grey15,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined,
                                  color: KaziColors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _isUploading
                                    ? t(context, 'profile.uploading')
                                    : t(context, 'profile.takeOrChoose'),
                                style: KaziTextStyles.subtitle
                                    .copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_photoPaths.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _photoPaths.length,
                          itemBuilder: (context, index) {
                            final path = _photoPaths[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image(
                                    image: platform_image
                                        .imageProviderFromPath(path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: KaziColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: KaziColors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
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
