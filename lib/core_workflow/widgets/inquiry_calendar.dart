import 'package:flutter/material.dart';
import 'package:kazi/core_workflow/widgets/availability_calendar.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

/// Calendar for an inquiry: red = day the problem started, blue = available days.
class InquiryCalendar extends StatefulWidget {
  const InquiryCalendar({
    super.key,
    required this.occurredOn,
    required this.availableDays,
    this.editable = false,
    this.onAvailableDaysChanged,
  });

  final DateTime occurredOn;
  final Set<DateTime> availableDays;
  final bool editable;
  final ValueChanged<Set<DateTime>>? onAvailableDaysChanged;

  static const availableBlue = Color(0xFF1E88E5);

  @override
  State<InquiryCalendar> createState() => _InquiryCalendarState();
}

class _InquiryCalendarState extends State<InquiryCalendar> {
  late DateTime _visibleMonth;
  OverlayEntry? _bubble;

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
  void initState() {
    super.initState();
    final start = AvailabilityCalendar.dateOnly(widget.occurredOn);
    _visibleMonth = DateTime(start.year, start.month);
  }

  @override
  void dispose() {
    _hideBubble();
    super.dispose();
  }

  DateTime get _occurred => AvailabilityCalendar.dateOnly(widget.occurredOn);

  Set<DateTime> get _available => widget.availableDays
      .map(AvailabilityCalendar.dateOnly)
      .toSet();

  void _hideBubble() {
    _bubble?.remove();
    _bubble = null;
  }

  void _showBubble(BuildContext cellContext, String message, Color color) {
    _hideBubble();
    final box = cellContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    final size = box.size;
    final overlay = Overlay.of(cellContext, rootOverlay: true);
    final screen = MediaQuery.sizeOf(cellContext);
    const bubbleWidth = 200.0;
    var left = origin.dx + size.width + 8;
    if (left + bubbleWidth > screen.width - 16) {
      left = origin.dx - bubbleWidth - 8;
    }
    if (left < 8) left = 8;

    _bubble = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideBubble,
              ),
            ),
            Positioned(
              left: left,
              top: origin.dy,
              width: bubbleWidth,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: KaziTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_bubble!);
  }

  void _onDayTap(BuildContext cellContext, DateTime date) {
    final isOccurred = date == _occurred;
    final isAvailable = _available.contains(date);
    final today = AvailabilityCalendar.dateOnly(DateTime.now());

    if (isOccurred) {
      _showBubble(
        cellContext,
        t(context, 'jobs.problemStarted'),
        KaziColors.urgent,
      );
      return;
    }

    if (widget.editable) {
      if (date.isBefore(today)) return;
      final next = Set<DateTime>.from(_available);
      if (isAvailable) {
        next.remove(date);
      } else {
        next.add(date);
      }
      widget.onAvailableDaysChanged?.call(next);
      return;
    }

    if (isAvailable) {
      _showBubble(
        cellContext,
        t(context, 'jobs.availableDaysHint'),
        InquiryCalendar.availableBlue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = (firstOfMonth.weekday + 6) % 7;
    final monthLabel =
        '${t(context, 'month.${_visibleMonth.month}')} ${_visibleMonth.year}';

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
                onPressed: () {
                  _hideBubble();
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                    );
                  });
                },
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
                onPressed: () {
                  _hideBubble();
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                    );
                  });
                },
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
              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                day,
              );
              final isOccurred = date == _occurred;
              final isAvailable = _available.contains(date);
              final today = AvailabilityCalendar.dateOnly(DateTime.now());
              final isPast = date.isBefore(today);
              final fill = isOccurred
                  ? KaziColors.urgent
                  : isAvailable
                      ? InquiryCalendar.availableBlue
                      : KaziColors.white;
              final textColor = isOccurred || isAvailable
                  ? Colors.white
                  : isPast
                      ? KaziColors.grey30
                      : KaziColors.textPrimary;

              return Builder(
                builder: (cellContext) {
                  return GestureDetector(
                    onTap: () => _onDayTap(cellContext, date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fill,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: KaziTextStyles.button.copyWith(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
