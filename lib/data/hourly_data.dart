// lib/data/hourly_data.dart

import 'package:flutter/material.dart';

/// HourlyItem represents a single hour's prediction card.
class HourlyItem {
  final String timeLabel;
  final int temperature;
  final IconData weatherIcon;
  final String condition;

  HourlyItem({
    required this.timeLabel,
    required this.temperature,
    required this.weatherIcon,
    required this.condition,
  });
}

/// Clearly identified demo/placeholder hourly forecast data.
/// (As permitted by the assignment since the Open-Meteo endpoint provides current weather).
/// Structure is modular so it can easily be replaced with live hourly API data.
final List<HourlyItem> placeholderHourlyData = [
  HourlyItem(
    timeLabel: 'NOW',
    temperature: 29,
    weatherIcon: Icons.water_drop_rounded,
    condition: 'Light Rain',
  ),
  HourlyItem(
    timeLabel: '5 PM',
    temperature: 28,
    weatherIcon: Icons.water_drop_rounded,
    condition: 'Light Rain',
  ),
  HourlyItem(
    timeLabel: '6 PM',
    temperature: 28,
    weatherIcon: Icons.cloud_queue_rounded,
    condition: 'Cloudy',
  ),
  HourlyItem(
    timeLabel: '7 PM',
    temperature: 27,
    weatherIcon: Icons.cloud_queue_rounded,
    condition: 'Cloudy',
  ),
  HourlyItem(
    timeLabel: '8 PM',
    temperature: 26,
    weatherIcon: Icons.nights_stay_rounded,
    condition: 'Clear Night',
  ),
  HourlyItem(
    timeLabel: '9 PM',
    temperature: 25,
    weatherIcon: Icons.nights_stay_rounded,
    condition: 'Clear Night',
  ),
];
