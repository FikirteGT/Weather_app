import 'package:flutter/material.dart';
import 'past_day_card.dart';

class WeatherTheme {
  final List<Color> bgGradients;
  final Color glowColor;
  final Color accentColor;

  WeatherTheme({
    required this.bgGradients,
    required this.glowColor,
    required this.accentColor,
  });
}

class PastDayWeatherCardWrapper extends StatelessWidget {
  final String dayLabel;
  final String temperature;
  final String imagePath;
  final double? width;
  final VoidCallback? onTap;

  const PastDayWeatherCardWrapper({
    super.key,
    required this.dayLabel,
    required this.temperature,
    required this.imagePath,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PastDayCard(
      dayLabel: dayLabel,
      temperature: temperature,
      imagePath: imagePath,
      width: width,
      onTap: onTap,
    );
  }
}
