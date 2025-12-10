import 'package:flutter/material.dart';

/// Widget pour le slider de vitesse
class SpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const SpeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Vitesse: ${value.toInt()}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

