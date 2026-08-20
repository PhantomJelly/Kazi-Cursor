import 'package:flutter/material.dart';

enum AppLanguage {
  english('English', Locale('en')),
  afrikaans('Afrikaans', Locale('af')),
  german('Deutsch', Locale('de')),
  portuguese('Português', Locale('pt'));

  const AppLanguage(this.label, this.locale);
  final String label;
  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('af'),
    Locale('de'),
    Locale('pt'),
  ];
}
