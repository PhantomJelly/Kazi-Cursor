import 'package:kazi/l10n/kazi_l10n.dart';

/// Jobs a worker can offer and a customer can search.
enum TradeCategory {
  electrician,
  plumber,
  gardener,
  outdoorCleaner,
  carpenter,
  handyman,
  indoorCleaner,
  poolTechnician;

  /// Maps stored names, including older values from before the trade list was cut.
  static TradeCategory? tryParse(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final trade in values) {
      if (trade.name == name) return trade;
    }
    return switch (name) {
      'cleaner' => indoorCleaner,
      'poolCleaner' => poolTechnician,
      _ => null,
    };
  }
}

extension TradeCategoryLabel on TradeCategory {
  String get label => tRaw('trade.$name');
}
