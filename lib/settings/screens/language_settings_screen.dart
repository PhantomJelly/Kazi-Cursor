import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/settings/models/app_language.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  @override
  void initState() {
    super.initState();
    SettingsStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    SettingsStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final selected = SettingsStore.instance.language;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(t(context, 'settings.languageTitle'), style: KaziTextStyles.button),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: AppLanguage.values.map((language) {
            final isSelected = language == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => SettingsStore.instance.setLanguage(language),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(language.label, style: KaziTextStyles.button),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isSelected
                            ? KaziColors.primary
                            : KaziColors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
