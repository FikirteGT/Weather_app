import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HourlyForecastCard extends StatelessWidget {
  final DateTime time;
  final double temperature;
  final String imagePath;
  final bool isCurrent;

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.temperature,
    required this.imagePath,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format hour (e.g. "08:00" or "Now" if current)
    final String timeLabel = isCurrent ? 'Now' : DateFormat('HH:mm').format(time);

    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: isCurrent 
            ? const Color(0xFF38BDF8).withOpacity(0.18) 
            : const Color(0xFF1B1C33).withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent 
              ? const Color(0xFF38BDF8).withOpacity(0.6) 
              : Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeLabel,
            style: GoogleFonts.inter(
              color: isCurrent ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Image.asset(
            imagePath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          Text(
            '${temperature.round()}°',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
