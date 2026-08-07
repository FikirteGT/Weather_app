class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final double apparentTemperature;
  final double precipitation;
  final List<PastDayWeather> pastDays;
  final double daylightHours;
  final DateTime localTime;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    this.apparentTemperature = 0.0,
    this.precipitation = 0.0,
    required this.pastDays,
    required this.daylightHours,
    required this.localTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json;
    final timeStr = current['time'] as String? ?? DateTime.now().toIso8601String();
    final localTime = DateTime.tryParse(timeStr) ?? DateTime.now();

    final currentTemp = (current['temperature_2m'] as num?)?.toDouble() ?? 29.0;
    final currentCode = (current['weather_code'] as num?)?.toInt() ?? 61;
    final currentHumidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 2;
    final currentWind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 11.0;

    final List<PastDayWeather> pastDaysList = [];
    double calculatedDaylightHours = 8.0;

    if (json['daily'] != null) {
      final daily = json['daily'];
      final times = daily['time'] as List<dynamic>? ?? [];
      final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
      final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
      final codes = daily['weather_code'] as List<dynamic>? ?? [];
      final daylightDurations = daily['daylight_duration'] as List<dynamic>? ?? [];

      // Open-Meteo with past_days=7 returns 7 past days, then today, then future days.
      // So indices 0 to 6 are the 7 past days.
      for (int i = 0; i < 7 && i < times.length; i++) {
        final dateStr = times[i] as String;
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
        final maxTemp = (maxTemps[i] as num?)?.toDouble() ?? currentTemp;
        final minTemp = (minTemps[i] as num?)?.toDouble() ?? (currentTemp - 5);
        final code = (codes[i] as num?)?.toInt() ?? currentCode;

        pastDaysList.add(PastDayWeather(
          dateLabel: _getWeekdayLabel(date),
          maxTemp: maxTemp,
          minTemp: minTemp,
          weatherCode: code,
          weatherImage: _getWeatherImageForCode(code),
        ));
      }

      // Today's daylight duration (index 7, or fallback to first element)
      if (daylightDurations.length > 7) {
        final durationSeconds = (daylightDurations[7] as num?)?.toDouble() ?? 0.0;
        calculatedDaylightHours = durationSeconds / 3600.0;
      } else if (daylightDurations.isNotEmpty) {
        final durationSeconds = (daylightDurations[0] as num?)?.toDouble() ?? 0.0;
        calculatedDaylightHours = durationSeconds / 3600.0;
      }
    }

    // Fallback if no daily data parsed
    if (pastDaysList.isEmpty) {
      for (int i = 7; i >= 1; i--) {
        final date = localTime.subtract(Duration(days: i));
        pastDaysList.add(PastDayWeather(
          dateLabel: _getWeekdayLabel(date),
          maxTemp: currentTemp - (i % 3),
          minTemp: currentTemp - 8 - (i % 2),
          weatherCode: 61,
          weatherImage: 'assets/image/heavy-rain.png',
        ));
      }
    }

    return WeatherData(
      temperature: currentTemp,
      humidity: currentHumidity,
      windSpeed: currentWind,
      weatherCode: currentCode,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? currentTemp,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      pastDays: pastDaysList,
      daylightHours: calculatedDaylightHours,
      localTime: localTime,
    );
  }

  String get weatherCondition {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Expect high rain today.';
    if (weatherCode <= 77) return 'Snow fall';
    if (weatherCode <= 82) return 'Rain showers';
    return 'Expect high rain today.';
  }

  String get conditionText => weatherCondition;

  String get weatherImage {
    return _getWeatherImageForCode(weatherCode);
  }

  static String _getWeatherImageForCode(int code) {
    if (code == 61 || code == 63 || code == 65 || code == 80 || code == 81 || code == 82) {
      return 'assets/image/heavy-rain.png';
    } else if (code <= 3) {
      return 'assets/image/cloudy.png';
    }
    return 'assets/image/heavy-rain.png';
  }

  static String _getWeekdayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      switch (date.weekday) {
        case DateTime.monday: return 'Mon';
        case DateTime.tuesday: return 'Tue';
        case DateTime.wednesday: return 'Wed';
        case DateTime.thursday: return 'Thu';
        case DateTime.friday: return 'Fri';
        case DateTime.saturday: return 'Sat';
        case DateTime.sunday: return 'Sun';
        default: return '';
      }
    }
  }
}

class PastDayWeather {
  final String dateLabel;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String weatherImage;

  PastDayWeather({
    required this.dateLabel,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.weatherImage,
  });
}
