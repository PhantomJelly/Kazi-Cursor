import 'package:kazi/l10n/kazi_l10n.dart';

enum WorkExperienceLevel {
  threeMonthsOrLess,
  threeToSixMonths,
  sixMonthsToOneYear,
  oneToTwoYears,
  twoToFiveYears,
  fiveToTenYears,
  tenPlusYears;
}

extension WorkExperienceLevelLabel on WorkExperienceLevel {
  String get label => tRaw('exp.$name');
}
