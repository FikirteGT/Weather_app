// lib/models/weather_model.dart

/// WeatherModel stores the live weather parameters fetched from Open-Meteo.
/// This class turns raw JSON key-value data into typed Dart variables.
class WeatherModel {
  final double temperature; // temperature in °C
  final int humidity; // relative humidity in %
  final double apparentTemperature; // feels-like temperature in °C
  final double precipitation; // precipitation in mm
  final int weatherCode; // WMO weather code number
  final double windSpeed; // wind speed in km/h
  final double windDirection; // wind direction in degrees

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
  });

  /// Factory constructor to create a WeatherModel from the JSON map
  /// returned by the Open-Meteo API.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Extract the 'current' object from the API response
    final current = json['current'] as Map<String, dynamic>? ?? json;

    return WeatherModel(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (current['wind_direction_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
