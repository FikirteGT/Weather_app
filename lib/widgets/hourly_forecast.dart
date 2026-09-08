// lib/widgets/hourly_forecast.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/hourly_data.dart';

/// HourlyForecastWidget renders a horizontally scrollable list of hourly weather cards.
/// Uses clearly identified placeholder data as permitted by the assignment specifications.
class HourlyForecastWidget extends StatelessWidget {
  const HourlyForecastWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hourly Forecast',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Demo / Placeholder Data',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 116,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: placeholderHourlyData.length,
            itemBuilder: (context, index) {
              final item = placeholderHourlyData[index];
              final bool isCurrent = index == 0;

              return Container(
                width: 76,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                      : const Color(0xFF1B1C33).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.timeLabel,
                      style: GoogleFonts.inter(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      item.weatherIcon,
                      color: isCurrent ? const Color(0xFF38BDF8) : Colors.white70,
                      size: 24,
                    ),
                    Text(
                      '${item.temperature}°',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
