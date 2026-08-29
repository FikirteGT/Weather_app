// lib/services/weather_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// WeatherService is responsible ONLY for network communication.
/// It fetches live weather data from Open-Meteo and returns a WeatherModel.
class WeatherService {
  // Open-Meteo endpoint URL for Addis Ababa (Latitude: 8.9806, Longitude: 38.7578)
  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m';

  /// Fetches current weather data asynchronously.
  /// Includes fallback sample data if network or CORS is unavailable.
  Future<WeatherModel> fetchCurrentWeather() async {
    final uri = Uri.parse(_baseUrl);

    try {
      // Send HTTP GET request with json headers
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network fetch failed: $e');
      rethrow;
    }
  }

  /// Provides fallback weather data for offline / web CORS restriction mode.
  static WeatherModel getFallbackWeather() {
    return WeatherModel(
      temperature: 29.0,
      humidity: 62,
      apparentTemperature: 30.0,
      precipitation: 0.4,
      weatherCode: 61, // Light Rain
      windSpeed: 11.0,
      windDirection: 180.0,
    );
  }
}
