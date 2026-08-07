import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherService {
  static const String _apiUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,daylight_duration&past_days=7';

  Future<WeatherData> fetchWeather() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
