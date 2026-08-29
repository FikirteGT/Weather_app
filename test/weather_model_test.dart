import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_models.dart';

void main() {
  group('WeatherData Model Tests', () {
    test('WeatherData.fromJson parses Open-Meteo payload correctly', () {
      final mockJson = {
        'current': {
          'time': '2026-08-29T10:00',
          'temperature_2m': 22.5,
          'relative_humidity_2m': 60,
          'apparent_temperature': 23.0,
          'precipitation': 0.0,
          'weather_code': 0,
          'wind_speed_10m': 12.4,
        },
        'aqi_current': {
          'us_aqi': 42,
          'pm2_5': 10.2,
          'pm10': 18.5,
        },
        'daily': {
          'time': ['2026-08-29', '2026-08-30'],
          'temperature_2m_max': [24.0, 25.0],
          'temperature_2m_min': [14.0, 15.0],
          'weather_code': [0, 1],
          'daylight_duration': [43200.0, 43200.0],
          'uv_index_max': [5.5, 6.0],
          'precipitation_probability_max': [10, 20],
        },
        'hourly': {
          'time': ['2026-08-29T10:00', '2026-08-29T11:00'],
          'temperature_2m': [22.5, 23.0],
          'weather_code': [0, 0],
        }
      };

      final weather = WeatherData.fromJson(mockJson);

      expect(weather.temperature, equals(22.5));
      expect(weather.humidity, equals(60));
      expect(weather.windSpeed, equals(12.4));
      expect(weather.weatherCondition, equals('Clear sky'));
      expect(weather.usAqi, equals(42));
      expect(weather.aqiStatus, equals('Good'));
      expect(weather.pm25, equals(10.2));
      expect(weather.dailyForecast.isNotEmpty, isTrue);
    });

    test('AQI status evaluation returns accurate category labels', () {
      final goodWeather = WeatherData(
        temperature: 20,
        humidity: 50,
        windSpeed: 10,
        weatherCode: 0,
        apparentTemperature: 20,
        precipitation: 0,
        daylightHours: 12,
        localTime: DateTime.now(),
        uvIndex: 2,
        precipitationProbability: 0,
        usAqi: 35,
        pastDays: [],
        hourlyForecast: [],
        dailyForecast: [],
      );
      expect(goodWeather.aqiStatus, equals('Good'));

      final unhealthyWeather = WeatherData(
        temperature: 20,
        humidity: 50,
        windSpeed: 10,
        weatherCode: 0,
        apparentTemperature: 20,
        precipitation: 0,
        daylightHours: 12,
        localTime: DateTime.now(),
        uvIndex: 2,
        precipitationProbability: 0,
        usAqi: 175,
        pastDays: [],
        hourlyForecast: [],
        dailyForecast: [],
      );
      expect(unhealthyWeather.aqiStatus, equals('Unhealthy'));
    });
  });
}
