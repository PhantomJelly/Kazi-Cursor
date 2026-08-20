import 'package:flutter/material.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class SpecializationSelector extends StatelessWidget {
  const SpecializationSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.maxSelection = 3,
  });

  final List<TradeCategory> selected;
  final ValueChanged<List<TradeCategory>> onChanged;
  final int maxSelection;

  void _toggle(TradeCategory category) {
    if (selected.contains(category)) {
      onChanged(selected.where((c) => c != category).toList());
      return;
    }
    if (selected.length >= maxSelection) return;
    onChanged([...selected, category]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t(context, 'profile.specialisation'), style: KaziTextStyles.label),
            Text(
              t(context, 'profile.selectedCount', {
                'count': '${selected.length}',
                'max': '$maxSelection',
              }),
              style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          t(context, 'profile.chooseTrades'),
          style: KaziTextStyles.subtitle.copyWith(
            fontSize: 13,
            color: KaziColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TradeCategory.values.map((category) {
            final isSelected = selected.contains(category);
            return GestureDetector(
              onTap: () => _toggle(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? KaziColors.primaryTint
                      : KaziColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? KaziColors.primary
                        : KaziColors.grey15,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  category.label,
                  style: KaziTextStyles.button.copyWith(
                    fontSize: 14,
                    color: isSelected
                        ? KaziColors.primary
                        : KaziColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
