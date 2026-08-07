import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PastDayCard extends StatelessWidget {
  final String dayLabel;
  final String temperature;
  final String imagePath;
  final double? width;

  const PastDayCard({
    super.key,
    required this.dayLabel,
    required this.temperature,
    required this.imagePath,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C33).withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayLabel,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Image.asset(
            imagePath,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          Text(
            temperature,
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
