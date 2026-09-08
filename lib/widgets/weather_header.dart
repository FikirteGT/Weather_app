// lib/widgets/weather_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

/// WeatherHeader renders:
/// - Navigation top bar (Menu icon, City location with Favorite Heart icon, Calendar icon)
/// - Weather illustration icon
/// - Big Temperature readout
/// - Condition title and Today's Mood tag
class WeatherHeader extends StatelessWidget {
  final WeatherModel weather;
  final String locationName;
  final bool isFavorite;
  final VoidCallback? onMenuTap;
  final VoidCallback? onFavoriteToggle;

  const WeatherHeader({
    super.key,
    required this.weather,
    this.locationName = 'Addis Ababa',
    this.isFavorite = false,
    this.onMenuTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final condition = WeatherUtils.getWeatherCondition(weather.weatherCode);
    final iconData = WeatherUtils.getWeatherIcon(weather.weatherCode);
    final mood = WeatherUtils.getWeatherMood(weather.weatherCode);

    return Column(
      children: [
        // Top Header Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu Icon (opens search overlay)
            GestureDetector(
              onTap: onMenuTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
              ),
            ),

            // Location Header with Heart Favorite Button
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 6),
                Text(
                  locationName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: isFavorite ? const Color(0xFFE57373) : Colors.white38,
                    size: 20,
                  ),
                ),
              ],
            ),

            // Calendar / Notifications Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Main Weather Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            iconData,
            size: 80,
            color: const Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(height: 16),

        // Temperature readout
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather.temperature.round()}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '°C',
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Human Readable Condition Text
        Text(
          condition,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Today's Mood Personality Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            mood,
            style: GoogleFonts.inter(
              color: const Color(0xFF38BDF8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
