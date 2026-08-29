import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_models.dart';

class WeatherAlertsDialog extends StatelessWidget {
  final WeatherData weather;

  const WeatherAlertsDialog({super.key, required this.weather});

  static void show(BuildContext context, WeatherData weather) {
    // Generate context-aware alerts list
    final List<Map<String, dynamic>> activeAlerts = [];
    
    // 1. Precipitation Alert
    if (weather.precipitation > 5.0) {
      activeAlerts.add({
        'icon': Icons.thunderstorm_rounded,
        'color': Colors.redAccent,
        'title': 'Heavy Rain Warning',
        'desc': 'Heavy rain detected (${weather.precipitation}mm). Expect wet roads and reduced visibility.',
      });
    } else if (weather.precipitation > 0.0) {
      activeAlerts.add({
        'icon': Icons.cloudy_snowing,
        'color': Colors.amber,
        'title': 'Light Precipitation',
        'desc': 'Light rain/drizzle is currently falling. Carrying an umbrella is advised.',
      });
    }

    // 2. Temperature Alert
    if (weather.temperature > 35.0) {
      activeAlerts.add({
        'icon': Icons.light_mode_rounded,
        'color': Colors.redAccent,
        'title': 'Extreme Heat Warning',
        'desc': 'Temperatures are extremely high (${weather.temperature.round()}°C). Stay hydrated and avoid direct sunlight.',
      });
    } else if (weather.temperature < 10.0) {
      activeAlerts.add({
        'icon': Icons.ac_unit_rounded,
        'color': Colors.lightBlueAccent,
        'title': 'Cold Weather Advisory',
        'desc': 'Chilly weather expected (${weather.temperature.round()}°C). Wear warm layers if going outdoors.',
      });
    }

    // 3. Air Quality Alert
    if (weather.usAqi != null && weather.usAqi! > 100) {
      activeAlerts.add({
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orangeAccent,
        'title': 'Poor Air Quality Alert',
        'desc': 'Air Quality Index is unhealthy (${weather.usAqi}). Sensitive groups should limit outdoor activities.',
      });
    } else if (weather.usAqi != null && weather.usAqi! > 50) {
      activeAlerts.add({
        'icon': Icons.info_outline_rounded,
        'color': Colors.amber,
        'title': 'Moderate Air Quality',
        'desc': 'Air Quality Index is moderate (${weather.usAqi}). No immediate threat to general public.',
      });
    }

    // 4. Activity tip
    if (weather.precipitation == 0.0 && weather.temperature >= 18 && weather.temperature <= 28) {
      activeAlerts.add({
        'icon': Icons.directions_run_rounded,
        'color': Colors.greenAccent,
        'title': 'Perfect Outdoor Conditions',
        'desc': 'Great day for outdoor exercises, running, or visiting the park. Enjoy the pleasant weather!',
      });
    } else {
      activeAlerts.add({
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.lightBlueAccent,
        'title': 'Daily Forecast Tip',
        'desc': 'Condition is ${weather.weatherCondition.toLowerCase()} with winds at ${weather.windSpeed.round()}km/h.',
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B1C33).withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Live Weather Alerts',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: activeAlerts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = activeAlerts[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (alert['color'] as Color).withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (alert['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            alert['icon'] as IconData,
                            color: alert['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert['title'] as String,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert['desc'] as String,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Dismiss',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
