import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // API URL for Addis Ababa
  static const String apiUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m';

  Future<WeatherData> fetchWeather() async {
    try {
      // Make the API call
      final response = await http.get(Uri.parse(apiUrl));

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON data
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Generate hourly forecast (placeholder data)
  List<Map<String, dynamic>> getHourlyForecast() {
    // Creating mock data for hourly forecast
    final now = DateTime.now();
    List<Map<String, dynamic>> hourlyData = [];

    for (int i = 0; i < 4; i++) {
      final time = now.add(Duration(hours: i));
      hourlyData.add({
        'time': time,
        'temperature': 28 - i, // Decreasing temperature for demo
      });
    }

    return hourlyData;
  }
}
