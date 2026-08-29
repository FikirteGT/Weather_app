import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_models.dart';

class ForecastDialogs {
  static String getWeatherConditionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snow fall';
    if (code <= 82) return 'Rain showers';
    return 'Thunderstorm';
  }

  static void showDaySummaryDialog(BuildContext context, dynamic p) {
    final String dayLabel = p is DailyForecast ? p.dateLabel : (p as PastDayWeather).dateLabel;
    final double maxTemp = p is DailyForecast ? p.maxTemp : (p as PastDayWeather).maxTemp;
    final double minTemp = p is DailyForecast ? p.minTemp : (p as PastDayWeather).minTemp;
    final int code = p is DailyForecast ? p.weatherCode : (p as PastDayWeather).weatherCode;
    final String img = p is DailyForecast ? p.weatherImage : (p as PastDayWeather).weatherImage;
    final String condition = getWeatherConditionFromCode(code);

    final int humidityVal = code >= 61 ? 85 : (code <= 3 ? 48 : 65);
    final double uvVal = code == 0 ? 7.5 : (code <= 3 ? 4.2 : 1.5);
    final double windSpeedVal = code >= 95 ? 24.5 : (code >= 61 ? 16.0 : 10.5);

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
                Text(
                  dayLabel == 'Today' 
                      ? 'Today\'s Weather' 
                      : (dayLabel == 'Yesterday' ? 'Yesterday\'s Weather' : '$dayLabel Weather'),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(img, width: 88, height: 88, fit: BoxFit.contain),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    condition,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      _buildDialogDetailRow('Temperature', '${minTemp.round()}°C to ${maxTemp.round()}°C'),
                      const Divider(color: Colors.white10),
                      _buildDialogDetailRow('Humidity (Avg)', '$humidityVal%'),
                      const Divider(color: Colors.white10),
                      _buildDialogDetailRow('Wind Speed', '${windSpeedVal.toStringAsFixed(1)} km/h'),
                      const Divider(color: Colors.white10),
                      _buildDialogDetailRow('UV Index', uvVal.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  static void showDetailedCalendarForecast(BuildContext context, WeatherData? weather) {
    if (weather == null) return;
    
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
                    const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '7-Day Calendar Forecast',
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
                itemCount: weather.dailyForecast.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final day = weather.dailyForecast[index];
                  final isToday = index == 0;
                  
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      showDaySummaryDialog(context, day);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.dateLabel,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                if (isToday)
                                  Text(
                                    'Today',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Image.asset(
                              day.weatherImage,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${day.minTemp.round()}° / ${day.maxTemp.round()}°',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white30,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
