import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class InquirySentScreen extends StatefulWidget {
  const InquirySentScreen({super.key});

  @override
  State<InquirySentScreen> createState() => _InquirySentScreenState();
}

class _InquirySentScreenState extends State<InquirySentScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: KaziColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: KaziColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text('Inquiry sent', style: KaziTextStyles.heading),
            ],
          ),
        ),
      ),
    );
  }
}
