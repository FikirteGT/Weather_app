import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

class WeatherService {
  static const String _weatherCacheKey = 'cached_weather_json';
  static const String _lastUpdatedCacheKey = 'cached_weather_time';
  
  static const String _cityCacheKey = 'cached_city_name';
  static const String _countryCacheKey = 'cached_city_country';
  static const String _latCacheKey = 'cached_city_lat';
  static const String _lonCacheKey = 'cached_city_lon';

  // Fetch weather data dynamically based on latitude & longitude.
  // Combines weather API data and air quality API data in parallel.
  Future<WeatherData> fetchWeather({double latitude = 8.9806, double longitude = 38.7578}) async {
    final weatherUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,daylight_duration,uv_index_max,precipitation_probability_max&hourly=temperature_2m,weather_code&past_days=7';
    final aqiUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$latitude&longitude=$longitude&current=pm2_5,pm10,us_aqi';

    try {
      // Execute both network requests in parallel
      final results = await Future.wait([
        http.get(Uri.parse(weatherUrl)),
        http.get(Uri.parse(aqiUrl)).catchError((_) => http.Response('{}', 404)), // Fallback if AQI fails
      ]);

      final weatherResponse = results[0];
      final aqiResponse = results[1];

      if (weatherResponse.statusCode == 200) {
        final Map<String, dynamic> weatherJson = jsonDecode(weatherResponse.body);
        
        // Merge AQI details if fetched successfully
        if (aqiResponse.statusCode == 200) {
          final Map<String, dynamic> aqiJson = jsonDecode(aqiResponse.body);
          if (aqiJson['current'] != null) {
            weatherJson['aqi_current'] = aqiJson['current'];
          }
        }

        // Cache the combined response and the current timestamp
        await _cacheWeatherData(weatherJson);
        
        return WeatherData.fromJson(weatherJson);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // If network request fails, try loading from cache
      final cachedData = await getCachedWeather();
      if (cachedData != null) {
        return WeatherData.fromJson(cachedData);
      }
      rethrow;
    }
  }

  // Fetch location suggestions using Open-Meteo's free keyless Geocoding API
  Future<List<Map<String, dynamic>>> fetchLocations(String query) async {
    if (query.trim().length < 2) return [];
    
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://geocoding-api.open-meteo.com/v1/search?name=$encodedQuery&count=8&language=en&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        
        return results.map((item) {
          return {
            'name': item['name']?.toString() ?? 'Unknown',
            'country': item['country']?.toString() ?? '',
            'admin1': item['admin1']?.toString() ?? '', // Region/State
            'latitude': (item['latitude'] as num?)?.toDouble() ?? 0.0,
            'longitude': (item['longitude'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();
      }
    } catch (e) {
      // Log or suppress geocoding errors
      debugPrint('Geocoding error: $e');
    }
    return [];
  }

  // --- Caching Helpers ---

  Future<void> _cacheWeatherData(Map<String, dynamic> weatherJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weatherCacheKey, jsonEncode(weatherJson));
      await prefs.setString(_lastUpdatedCacheKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Failed to cache weather data: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_weatherCacheKey);
      if (cachedStr != null) {
        return jsonDecode(cachedStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to load cached weather data: $e');
    }
    return null;
  }

  Future<String?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdatedCacheKey);
  }

  // Save selected city details
  Future<void> saveSelectedCity(String name, String country, double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityCacheKey, name);
      await prefs.setString(_countryCacheKey, country);
      await prefs.setDouble(_latCacheKey, lat);
      await prefs.setDouble(_lonCacheKey, lon);
    } catch (e) {
      debugPrint('Failed to cache selected city: $e');
    }
  }

  // Retrieve cached city details (defaults to Addis Ababa if empty)
  Future<Map<String, dynamic>> getSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_cityCacheKey);
      final country = prefs.getString(_countryCacheKey);
      final lat = prefs.getDouble(_latCacheKey);
      final lon = prefs.getDouble(_lonCacheKey);

      if (name != null && lat != null && lon != null) {
        return {
          'name': name,
          'country': country ?? '',
          'latitude': lat,
          'longitude': lon,
        };
      }
    } catch (e) {
      debugPrint('Failed to load cached selected city: $e');
    }
    
    // Default fallback: Addis Ababa, Ethiopia
    return {
      'name': 'Addis Ababa',
      'country': 'Ethiopia',
      'latitude': 8.9806,
      'longitude': 38.7578,
    };
  }
}
