// lib/widgets/weather_info_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';

/// WeatherInfoCard displays current weather metrics:
/// - Wind Speed (km/h)
/// - Humidity (%)
/// - Feels Like Temperature (°C)
/// - Precipitation (mm)
class WeatherInfoCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherInfoCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C33).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.air_rounded,
            label: 'Wind',
            value: '${weather.windSpeed.round()} km/h',
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: Icons.opacity_rounded,
            label: 'Humidity',
            value: '${weather.humidity}%',
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: Icons.thermostat_rounded,
            label: 'Feels Like',
            value: '${weather.apparentTemperature.round()}°C',
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: Icons.water_drop_outlined,
            label: 'Precip',
            value: '${weather.precipitation} mm',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
