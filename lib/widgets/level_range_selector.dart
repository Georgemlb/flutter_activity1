// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// 7 bands × 3 ticks = 21 steps (0..20)
const _bands = <String>[
  'Beginner', 'INTERMEDIATE', 'LEVEL G', 'LEVEL F', 'LEVEL E', 'LEVEL D', 'OPEN',
];
const _ticks = <String>['W', 'M', 'S'];

/// Public helper (you can reuse in list tiles)
String levelStepToLabel(int step) {
  final band = step ~/ 3;   // 0..6
  final tick = step % 3;    // 0..2
  final tickWord = switch (tick) { 0 => 'Weak', 1 => 'Mid', _ => 'Strong' };
  final bandShort = switch (_bands[band].toUpperCase()) {
    'INTERMEDIATE' => 'Intermediate',
    'LEVEL G'      => 'G',
    'LEVEL F'      => 'F',
    'LEVEL E'      => 'E',
    'LEVEL D'      => 'D',
    'OPEN'         => 'Open Player',
    _              => 'Beginner',
  };
  return '$tickWord $bandShort';
}

class LevelRangeSelector extends StatelessWidget {
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final String title;
  const LevelRangeSelector({
    super.key,
    required this.values,
    required this.onChanged,
    this.title = 'LEVEL',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 1.0,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            )),
        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 7,
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            activeTrackColor: theme.colorScheme.primary.withOpacity(.75),
            inactiveTrackColor: theme.colorScheme.primary.withOpacity(.20),
          ),
          child: RangeSlider(
            values: values,
            min: 0,
            max: 20,
            divisions: 20,
            labels: RangeLabels(
              levelStepToLabel(values.start.round()),
              levelStepToLabel(values.end.round()),
            ),
            onChanged: onChanged,
          ),
        ),

        const SizedBox(height: 6),

        // W M S ticks (21 positions)
        Row(
          children: List.generate(21, (i) {
            final tick = _ticks[i % 3];
            return Expanded(
              child: Center(
                child: Text(
                  tick,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color:
                        theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),

        // Band labels (each spans 3 ticks)
        Row(
          children: List.generate(_bands.length, (i) {
            return Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  _bands[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 6.8,
                    letterSpacing: .5,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
