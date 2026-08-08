import 'package:flutter/material.dart';

class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final double apparentTemperature;
  final double precipitation;
  final double daylightHours;
  final DateTime localTime;
  
  // New features
  final double uvIndex;
  final int precipitationProbability;
  final int? usAqi;
  final double? pm25;
  final double? pm10;
  
  // Forecast lists
  final List<PastDayWeather> pastDays;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.apparentTemperature,
    required this.precipitation,
    required this.daylightHours,
    required this.localTime,
    required this.uvIndex,
    required this.precipitationProbability,
    this.usAqi,
    this.pm25,
    this.pm10,
    required this.pastDays,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  bool get isNight {
    final hour = localTime.hour;
    return hour >= 18 || hour < 6;
  }

  String get weatherCondition {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snow fall';
    if (weatherCode <= 82) return 'Rain showers';
    return 'Thunderstorm';
  }

  String get conditionText => weatherCondition;

  String get weatherImage {
    return _getWeatherImageForCode(weatherCode, isNight: isNight);
  }

  static String _getWeatherImageForCode(int code, {bool isNight = false}) {
    // 61, 63, 65, 80, 81, 82 are rain codes
    if (code == 61 || code == 63 || code == 65 || code == 80 || code == 81 || code == 82 || code >= 95) {
      return 'assets/image/heavy-rain.png';
    } else if (isNight) {
      return 'assets/image/night.png';
    } else if (code <= 3) {
      return 'assets/image/cloudy.png';
    }
    return 'assets/image/heavy-rain.png';
  }

  // Air Quality status labels
  String get aqiStatus {
    if (usAqi == null) return "Unknown";
    if (usAqi! <= 50) return "Good";
    if (usAqi! <= 100) return "Moderate";
    if (usAqi! <= 150) return "Unhealthy for Sensitive Groups";
    if (usAqi! <= 200) return "Unhealthy";
    if (usAqi! <= 300) return "Very Unhealthy";
    return "Hazardous";
  }

  Color get aqiColor {
    if (usAqi == null) return Colors.grey;
    if (usAqi! <= 50) return const Color(0xFF4CAF50); // Green
    if (usAqi! <= 100) return const Color(0xFFFFD54F); // Light Yellow/Amber
    if (usAqi! <= 150) return const Color(0xFFFF9800); // Orange
    if (usAqi! <= 200) return const Color(0xFFE57373); // Light Red
    return const Color(0xFFBA68C8); // Purple
  }

  // Smart Weather-Based Activity Suggestion
  String get activitySuggestion {
    if (precipitation > 1.5) {
      return "Heavy rain is falling. It is a perfect day to stay cozy indoors with a warm drink!";
    }
    if (weatherCode >= 51 && weatherCode <= 67) {
      return "Expect rain today. Make sure to carry an umbrella and wear water-resistant shoes.";
    }
    if (weatherCode >= 80 && weatherCode <= 82) {
      return "Rain showers are active. Don't forget your raincoat if you are heading out.";
    }
    if (usAqi != null && usAqi! > 100) {
      return "Air quality is poor (AQI: $usAqi). It's best to avoid prolonged outdoor exercise today.";
    }
    if (windSpeed > 28.0) {
      return "It's very windy outside ($windSpeed km/h). Hold onto your hats and avoid cycling.";
    }
    if (temperature > 32.0) {
      return "Hot day ahead! Wear sunscreen, stay hydrated, and try to limit direct sunlight.";
    }
    if (temperature < 10.0) {
      return "It's quite chilly ($temperature°C). Bundle up in warm layers before going out.";
    }
    if (uvIndex > 6.0) {
      return "High UV levels today. Wear sunglasses, a wide-brimmed hat, and apply sunscreen.";
    }
    return "Wonderful weather! It's a great day for outdoor activities, running, or a walk in the park.";
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json;
    final timeStr = current['time'] as String? ?? DateTime.now().toIso8601String();
    final localTime = DateTime.tryParse(timeStr) ?? DateTime.now();

    final currentTemp = (current['temperature_2m'] as num?)?.toDouble() ?? 20.0;
    final currentCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final currentHumidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 50;
    final currentWind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
    final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? currentTemp;
    final currentPrecip = (current['precipitation'] as num?)?.toDouble() ?? 0.0;

    // Air Quality Data (combined in service)
    int? parsedAqi;
    double? parsedPm25;
    double? parsedPm10;
    if (json['aqi_current'] != null) {
      final aqiData = json['aqi_current'];
      parsedAqi = (aqiData['us_aqi'] as num?)?.toInt();
      parsedPm25 = (aqiData['pm2_5'] as num?)?.toDouble();
      parsedPm10 = (aqiData['pm10'] as num?)?.toDouble();
    }

    final List<PastDayWeather> pastDaysList = [];
    final List<DailyForecast> dailyForecastList = [];
    double calculatedDaylightHours = 8.0;
    double maxUvIndex = 1.0;
    int maxPrecipProb = 0;

    if (json['daily'] != null) {
      final daily = json['daily'];
      final times = daily['time'] as List<dynamic>? ?? [];
      final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
      final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
      final codes = daily['weather_code'] as List<dynamic>? ?? [];
      final daylightDurations = daily['daylight_duration'] as List<dynamic>? ?? [];
      
      // Optional fields in query:
      final uvIndices = daily['uv_index_max'] as List<dynamic>? ?? [];
      final precipProbs = daily['precipitation_probability_max'] as List<dynamic>? ?? [];

      final todayStr = "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}";

      for (int i = 0; i < times.length; i++) {
        final dateStr = times[i] as String;
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
        final maxTemp = (maxTemps[i] as num?)?.toDouble() ?? currentTemp;
        final minTemp = (minTemps[i] as num?)?.toDouble() ?? (currentTemp - 5);
        final code = (codes[i] as num?)?.toInt() ?? currentCode;

        // Categorize into past days and future days based on date comparison
        if (dateStr.compareTo(todayStr) < 0) {
          // Date is in the past
          pastDaysList.add(PastDayWeather(
            dateLabel: _getWeekdayLabel(date),
            maxTemp: maxTemp,
            minTemp: minTemp,
            weatherCode: code,
            weatherImage: _getWeatherImageForCode(code, isNight: false),
          ));
        } else {
          // Date is today or in the future
          dailyForecastList.add(DailyForecast(
            date: date,
            dateLabel: dateStr == todayStr ? 'Today' : _getWeekdayLabel(date),
            maxTemp: maxTemp,
            minTemp: minTemp,
            weatherCode: code,
            weatherImage: _getWeatherImageForCode(code, isNight: false),
          ));

          if (dateStr == todayStr) {
            // Extract today's metrics
            if (daylightDurations.isNotEmpty && i < daylightDurations.length) {
              final durationSeconds = (daylightDurations[i] as num?)?.toDouble() ?? 0.0;
              calculatedDaylightHours = durationSeconds / 3600.0;
            }
            if (uvIndices.isNotEmpty && i < uvIndices.length) {
              maxUvIndex = (uvIndices[i] as num?)?.toDouble() ?? 1.0;
            }
            if (precipProbs.isNotEmpty && i < precipProbs.length) {
              maxPrecipProb = (precipProbs[i] as num?)?.toInt() ?? 0;
            }
          }
        }
      }
    }

    // Fallbacks if lists are empty
    if (pastDaysList.isEmpty) {
      for (int i = 7; i >= 1; i--) {
        final date = localTime.subtract(Duration(days: i));
        pastDaysList.add(PastDayWeather(
          dateLabel: _getWeekdayLabel(date),
          maxTemp: currentTemp - (i % 3),
          minTemp: currentTemp - 8 - (i % 2),
          weatherCode: 0,
          weatherImage: 'assets/image/cloudy.png',
        ));
      }
    }
    if (dailyForecastList.isEmpty) {
      for (int i = 0; i < 7; i++) {
        final date = localTime.add(Duration(days: i));
        dailyForecastList.add(DailyForecast(
          date: date,
          dateLabel: i == 0 ? 'Today' : _getWeekdayLabel(date),
          maxTemp: currentTemp + (i % 3),
          minTemp: currentTemp - 5 - (i % 2),
          weatherCode: 0,
          weatherImage: 'assets/image/cloudy.png',
        ));
      }
    }

    // Hourly Forecast (filtering for the next 24 hours starting from current hour)
    final List<HourlyForecast> hourlyForecastList = [];
    if (json['hourly'] != null) {
      final hourly = json['hourly'];
      final times = hourly['time'] as List<dynamic>? ?? [];
      final temps = hourly['temperature_2m'] as List<dynamic>? ?? [];
      final codes = hourly['weather_code'] as List<dynamic>? ?? [];

      // Find current hour threshold (rounded down to start of the hour)
      final thresholdTime = DateTime(localTime.year, localTime.month, localTime.day, localTime.hour);

      for (int i = 0; i < times.length; i++) {
        final hourTime = DateTime.tryParse(times[i] as String) ?? DateTime.now();
        
        // Add if it is within the next 24 hours starting now
        if ((hourTime.isAtSameMomentAs(thresholdTime) || hourTime.isAfter(thresholdTime)) &&
            hourTime.isBefore(thresholdTime.add(const Duration(hours: 24)))) {
          final tempVal = (temps[i] as num?)?.toDouble() ?? currentTemp;
          final codeVal = (codes[i] as num?)?.toInt() ?? currentCode;
          final isHourNight = hourTime.hour >= 18 || hourTime.hour < 6;

          hourlyForecastList.add(HourlyForecast(
            time: hourTime,
            temperature: tempVal,
            weatherCode: codeVal,
            weatherImage: _getWeatherImageForCode(codeVal, isNight: isHourNight),
          ));
        }
      }
    }

    // Fallback hourly forecast if none parsed
    if (hourlyForecastList.isEmpty) {
      for (int i = 0; i < 24; i++) {
        final hourTime = localTime.add(Duration(hours: i));
        final isHourNight = hourTime.hour >= 18 || hourTime.hour < 6;
        hourlyForecastList.add(HourlyForecast(
          time: hourTime,
          temperature: currentTemp + (i % 4 - 2),
          weatherCode: currentCode,
          weatherImage: _getWeatherImageForCode(currentCode, isNight: isHourNight),
        ));
      }
    }

    return WeatherData(
      temperature: currentTemp,
      humidity: currentHumidity,
      windSpeed: currentWind,
      weatherCode: currentCode,
      apparentTemperature: apparentTemp,
      precipitation: currentPrecip,
      daylightHours: calculatedDaylightHours,
      localTime: localTime,
      uvIndex: maxUvIndex,
      precipitationProbability: maxPrecipProb,
      usAqi: parsedAqi,
      pm25: parsedPm25,
      pm10: parsedPm10,
      pastDays: pastDaysList,
      hourlyForecast: hourlyForecastList,
      dailyForecast: dailyForecastList,
    );
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

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final String weatherImage;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.weatherImage,
  });
}

class DailyForecast {
  final DateTime date;
  final String dateLabel;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String weatherImage;

  DailyForecast({
    required this.date,
    required this.dateLabel,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.weatherImage,
  });
}
