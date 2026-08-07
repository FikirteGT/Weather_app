import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const WeatherInfoItem({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.85),
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
