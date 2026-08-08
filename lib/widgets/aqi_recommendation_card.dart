import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AqiRecommendationCard extends StatelessWidget {
  final int? aqi;
  final String aqiStatus;
  final Color aqiColor;
  final double? pm25;
  final double? pm10;
  final String recommendation;

  const AqiRecommendationCard({
    super.key,
    required this.aqi,
    required this.aqiStatus,
    required this.aqiColor,
    required this.pm25,
    required this.pm10,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C33).withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AQI & Suggestion Titles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.air_rounded,
                    color: const Color(0xFF38BDF8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Air Quality & Tips',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (aqi != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: aqiColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'AQI $aqi',
                    style: GoogleFonts.inter(
                      color: aqiColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // AQI Status Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                        children: [
                          const TextSpan(text: 'Air Status: '),
                          TextSpan(
                            text: aqiStatus,
                            style: TextStyle(
                              color: aqiColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (pm25 != null || pm10 != null)
                      Text(
                        'PM2.5: ${pm25?.toStringAsFixed(1) ?? 'N/A'} μg/m³  •  PM10: ${pm10?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: Colors.white10,
              height: 1,
            ),
          ),

          // Suggestion Tip Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF38BDF8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendation,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
