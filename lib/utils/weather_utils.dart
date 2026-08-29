// lib/utils/weather_utils.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

/// Helper class containing deterministic rules for:
/// 1. WMO Weather Code interpretation
/// 2. Weather Advice Engine
/// 3. Today's Outfit recommendations
/// 4. Outdoor Activity Score (0-100)
/// 5. Today's Mood
/// 6. Weather-responsive visual theme colors
class WeatherUtils {
  /// Converts WMO weather_code into a human-readable string description.
  static String getWeatherCondition(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowfall';
    if (code <= 82) return 'Rain showers';
    if (code == 95) return 'Thunderstorm';
    if (code >= 96) return 'Thunderstorm with hail';
    return 'Overcast';
  }

  /// Returns an appropriate Flutter Material Icon for a given weather_code.
  static IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_queue_rounded;
    if (code <= 48) return Icons.blur_on_rounded;
    if (code <= 57) return Icons.grain_rounded;
    if (code <= 67) return Icons.umbrella_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    if (code <= 82) return Icons.water_drop_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  /// **Weather Advice Engine**
  /// Analyzes live weather metrics and returns actionable advice items.
  static List<String> getWeatherAdvice(WeatherModel weather) {
    final List<String> adviceList = [];

    // 1. Temperature Advice
    if (weather.temperature >= 30.0) {
      adviceList.add('Hot weather — stay hydrated and avoid prolonged heat exposure.');
    } else if (weather.temperature >= 20.0) {
      adviceList.add('Comfortable temperature — light clothing is recommended.');
    } else if (weather.temperature >= 15.0) {
      adviceList.add('Cool weather — consider wearing a light jacket.');
    } else {
      adviceList.add('Cold weather — warm clothing and layers are recommended.');
    }

    // 2. Rain & Precipitation Advice
    if (weather.precipitation > 0.0 || (weather.weatherCode >= 51 && weather.weatherCode <= 82)) {
      adviceList.add('Rain is present or expected — carry an umbrella and wear water-resistant shoes.');
    }

    // 3. Wind Speed Advice
    if (weather.windSpeed > 30.0) {
      adviceList.add('Strong winds (${weather.windSpeed.round()} km/h) — be careful during outdoor activities.');
    } else if (weather.windSpeed > 15.0) {
      adviceList.add('Breezy conditions — enjoy the pleasant air flow.');
    }

    return adviceList;
  }

  /// **Outfit Recommendation Engine**
  /// Generates clothing recommendations based on temperature and rain.
  static List<String> getOutfitRecommendation(WeatherModel weather) {
    final List<String> outfitItems = [];

    if (weather.temperature >= 30.0) {
      outfitItems.add('Light T-shirt and breathable shorts or trousers');
      outfitItems.add('Sunglasses & sunscreen');
    } else if (weather.temperature >= 20.0) {
      outfitItems.add('Comfortable T-shirt or casual shirt');
      outfitItems.add('Light pants or jeans');
    } else if (weather.temperature >= 15.0) {
      outfitItems.add('Light jacket or sweater');
      outfitItems.add('Long trousers');
    } else {
      outfitItems.add('Warm coat, sweater, and warm trousers');
      outfitItems.add('Scarf or beanie if chilly');
    }

    if (weather.precipitation > 0.0 || (weather.weatherCode >= 51 && weather.weatherCode <= 82)) {
      outfitItems.add('Umbrella & raincoat');
    }

    return outfitItems;
  }

  /// **Outdoor Activity Score (0–100)**
  /// Computes a score based on rain, temperature, and wind.
  static Map<String, dynamic> getOutdoorActivityScore(WeatherModel weather) {
    int score = 100;

    // Deductions
    if (weather.precipitation > 2.0) {
      score -= 40;
    } else if (weather.precipitation > 0.0) {
      score -= 20;
    }

    if (weather.temperature > 32.0 || weather.temperature < 10.0) {
      score -= 25;
    } else if (weather.temperature > 28.0 || weather.temperature < 15.0) {
      score -= 10;
    }

    if (weather.windSpeed > 30.0) {
      score -= 20;
    } else if (weather.windSpeed > 20.0) {
      score -= 10;
    }

    score = score.clamp(0, 100);

    String status;
    Color color;

    if (score >= 80) {
      status = 'Excellent';
      color = const Color(0xFF4CAF50); // Green
    } else if (score >= 60) {
      status = 'Good';
      color = const Color(0xFF38BDF8); // Light Blue
    } else if (score >= 40) {
      status = 'Moderate';
      color = const Color(0xFFFFB74D); // Amber
    } else {
      status = 'Poor';
      color = const Color(0xFFE57373); // Red
    }

    return {
      'score': score,
      'status': status,
      'color': color,
    };
  }

  /// **Today's Mood / Personality**
  static String getWeatherMood(int code) {
    if (code == 0) return '☀ Perfect day to get outside and enjoy the sun!';
    if (code <= 3) return '☁ A calm, breezy, and pleasant cloudy day.';
    if (code <= 67 || code <= 82) return '🌧 Looks like the sky needs an umbrella today.';
    if (code >= 95) return '⛈ Dark clouds & thunder — cozy indoor weather!';
    return '🌤 A peaceful day ahead.';
  }

  /// **Weather-Responsive Visual Theme Gradients**
  static List<Color> getWeatherThemeGradients(WeatherModel? weather) {
    if (weather == null) {
      return [const Color(0xFF1B1936), const Color(0xFF0F0E20), const Color(0xFF0A0914)];
    }

    final code = weather.weatherCode;

    // Rainy / Stormy: Dark blue gradients
    if (weather.precipitation > 0.0 || (code >= 51 && code <= 82) || code >= 95) {
      return [const Color(0xFF151B29), const Color(0xFF0C1019), const Color(0xFF06080D)];
    }

    // Cloudy / Foggy: Slate blue gradients
    if (code <= 3 || code == 45 || code == 48) {
      return [const Color(0xFF18202B), const Color(0xFF0D1219), const Color(0xFF06090D)];
    }

    // Clear / Sunny: Warm deep purple & golden glowing accent
    return [const Color(0xFF1B1936), const Color(0xFF0F0E20), const Color(0xFF0A0914)];
  }
}
