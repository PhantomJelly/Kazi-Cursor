import 'package:flutter/material.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class AvailabilityCalendar extends StatelessWidget {
  const AvailabilityCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDays,
    required this.onMonthChanged,
    required this.onDayToggled,
  });

  final DateTime visibleMonth;
  final Set<DateTime> selectedDays;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDayToggled;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static const _weekdayKeys = [
    'weekday.m',
    'weekday.t',
    'weekday.w',
    'weekday.th',
    'weekday.f',
    'weekday.s',
    'weekday.su',
  ];

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingEmpty = (firstOfMonth.weekday + 6) % 7;
    final today = dateOnly(DateTime.now());
    final monthLabel =
        '${t(context, 'month.${visibleMonth.month}')} ${visibleMonth.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KaziColors.grey15, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month - 1),
                ),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: KaziColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  style: KaziTextStyles.button,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month + 1),
                ),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: KaziColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _weekdayKeys
                .map(
                  (key) => Expanded(
                    child: Text(
                      t(context, key),
                      textAlign: TextAlign.center,
                      style: KaziTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmpty + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox.shrink();
              final day = index - leadingEmpty + 1;
              final date = DateTime(visibleMonth.year, visibleMonth.month, day);
              final isPast = date.isBefore(today);
              final isSelected = selectedDays.contains(date);
              final isToday = date == today;

              return GestureDetector(
                onTap: isPast ? null : () => onDayToggled(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? KaziColors.primary
                        : isToday
                            ? KaziColors.primaryTint
                            : KaziColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: KaziTextStyles.button.copyWith(
                      fontSize: 13,
                      color: isPast
                          ? KaziColors.grey30
                          : isSelected
                              ? KaziColors.grey
                              : KaziColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
