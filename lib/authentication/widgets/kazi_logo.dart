import 'package:flutter/material.dart';
import 'package:kazi/authentication/widgets/hammer_icon.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

/// "Kazi" wordmark with a horizontal hammer swinging down onto the dot on the "i".
class KaziLogo extends StatefulWidget {
  const KaziLogo({
    super.key,
    this.fontSize = 56,
    this.color = KaziColors.white,
  });

  final double fontSize;
  final Color color;

  @override
  State<KaziLogo> createState() => _KaziLogoState();
}

class _KaziLogoState extends State<KaziLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _hammerSwing;
  late final Animation<double> _dotSquash;

  /// ~5 mm above the dot at typical screen density (logical pixels).
  static const double _gapAboveDotMm = 18;

  /// Raised position — head sits ~5 mm above the dot.
  static const double _swingStart = -0.58;

  /// Strike position — head bottom meets the very top of the dot.
  static const double _swingEnd = 0.32;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    _hammerSwing = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: _swingStart, end: _swingEnd)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: _swingEnd, end: _swingStart)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _dotSquash = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.72)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize;
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: widget.color,
      height: 1.0,
      letterSpacing: -1,
    );

    final dotSize = fontSize * 0.13;
    final stemWidth = fontSize * 0.11;
    final stemHeight = fontSize * 0.72;
    final dotGap = fontSize * 0.08;
    final letterWidth = fontSize * 0.28;
    final hammerLength = fontSize * 1.05;
    final hammerHeight = hammerLength * 0.38;
    final iColumnWidth = letterWidth + hammerLength * 0.55;
    final logoShiftLeft = hammerLength * 0.28;

    // Very top of the dot measured from the stack bottom.
    final dotTop = stemHeight + dotGap + dotSize;

    // Pivot (handle base) sits above the dot; hammer swings down to dot top.
    final pivotBottom = dotTop + _gapAboveDotMm + hammerLength * 0.38;
    final hammerBottom = pivotBottom - hammerHeight / 2;

    final stackHeight =
        stemHeight + dotSize + dotGap + _gapAboveDotMm + hammerLength * 0.55;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-logoShiftLeft, 0),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Kaz', style: style),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(
                    width: iColumnWidth,
                    height: stackHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomLeft,
                      children: [
                        Positioned(
                          left: (letterWidth - stemWidth) / 2,
                          bottom: 0,
                          child: Container(
                            width: stemWidth,
                            height: stemHeight,
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius:
                                  BorderRadius.circular(stemWidth / 2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: (letterWidth - dotSize) / 2,
                          bottom: stemHeight + dotGap,
                          child: Transform.scale(
                            scale: _dotSquash.value,
                            child: Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: BoxDecoration(
                                color: widget.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: hammerBottom,
                          child: Transform.rotate(
                            angle: _hammerSwing.value,
                            alignment: Alignment.centerRight,
                            child: HammerIcon(
                              size: hammerLength,
                              color: widget.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
