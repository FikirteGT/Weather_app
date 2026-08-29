// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// WeatherService is responsible ONLY for network communication.
/// It fetches live weather data from Open-Meteo and returns a WeatherModel.
class WeatherService {
  // Open-Meteo endpoint URL for Addis Ababa (Latitude: 8.9806, Longitude: 38.7578)
  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m';

  /// Fetches current weather data asynchronously.
  /// Throws an Exception if the network request fails or status code is not 200.
  Future<WeatherModel> fetchCurrentWeather() async {
    final uri = Uri.parse(_baseUrl);

    // Send HTTP GET request to the Open-Meteo API
    final response = await http.get(uri);

    // Verify successful HTTP response
    if (response.statusCode == 200) {
      // Decode raw JSON string into a Dart Map
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Parse JSON map into our WeatherModel object
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }
}
