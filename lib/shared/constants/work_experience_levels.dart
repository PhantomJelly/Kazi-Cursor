enum WorkExperienceLevel {
  threeMonthsOrLess('3 months or less'),
  threeToSixMonths('3–6 months'),
  sixMonthsToOneYear('6 months – 1 year'),
  oneToTwoYears('1–2 years'),
  twoToFiveYears('2–5 years'),
  fiveToTenYears('5–10 years'),
  tenPlusYears('10+ years');

  const WorkExperienceLevel(this.label);
  final String label;
}
