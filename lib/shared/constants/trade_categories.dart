enum TradeCategory {
  plumber('Plumber'),
  cleaner('Cleaner'),
  painter('Painter'),
  handyman('Handyman'),
  carpenter('Carpenter'),
  welder('Welder'),
  gardener('Gardener'),
  poolTechnician('Pool Technician'),
  poolCleaner('Pool Cleaner');

  const TradeCategory(this.label);
  final String label;
}
