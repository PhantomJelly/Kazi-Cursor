import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class KaziTextStyles {
  KaziTextStyles._();

  static const _base = TextStyle(
    color: KaziColors.textPrimary,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get logo => _base.copyWith(
        fontSize: 72,
        letterSpacing: -2,
      );

  static TextStyle get welcome => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get heading => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get subtitle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: KaziColors.textSecondary,
        height: 1.45,
      );

  static TextStyle get button => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get footer => const TextStyle(
        fontSize: 15,
        color: KaziColors.textSecondary,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get footerLink => _base.copyWith(
        fontSize: 15,
        color: KaziColors.primary,
      );

  static TextStyle get label => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelLight => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: KaziColors.grey,
      );

  static TextStyle get input => const TextStyle(
        fontSize: 16,
        color: KaziColors.textPrimary,
        fontWeight: FontWeight.w400,
      );
}
