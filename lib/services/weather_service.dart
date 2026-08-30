// lib/services/weather_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// WeatherService is responsible ONLY for network communication.
/// It fetches live weather data and location search results from Open-Meteo.
class WeatherService {
  /// Fetches current weather data for any given latitude & longitude (defaults to Addis Ababa).
  Future<WeatherModel> fetchCurrentWeather({
    double latitude = 8.9806,
    double longitude = 38.7578,
  }) async {
    final Uri uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        debugPrint('Open-Meteo returned status code: ${response.statusCode}, body: ${response.body}');
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network fetch failed: $e');
      rethrow;
    }
  }

  /// Fetches city location search suggestions using Open-Meteo's keyless Geocoding API.
  Future<List<Map<String, dynamic>>> fetchLocations(String query) async {
    if (query.trim().length < 2) return [];

    final Uri uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        return results.map((item) {
          return {
            'name': item['name']?.toString() ?? 'Unknown',
            'country': item['country']?.toString() ?? '',
            'admin1': item['admin1']?.toString() ?? '',
            'latitude': (item['latitude'] as num?)?.toDouble() ?? 8.9806,
            'longitude': (item['longitude'] as num?)?.toDouble() ?? 38.7578,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Geocoding search error: $e');
    }
    return [];
  }

  /// Provides fallback weather data for offline / web network restriction mode.
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
