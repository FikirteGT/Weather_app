// test/weather_companion_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/weather_utils.dart';

void main() {
  group('Weather Companion App Tests', () {
    test('WeatherModel parses Open-Meteo current weather payload correctly', () {
      final mockJson = {
        'current': {
          'temperature_2m': 29.0,
          'relative_humidity_2m': 62,
          'apparent_temperature': 30.0,
          'precipitation': 0.4,
          'weather_code': 61,
          'wind_speed_10m': 11.0,
          'wind_direction_10m': 180.0,
        }
      };

      final model = WeatherModel.fromJson(mockJson);

      expect(model.temperature, equals(29.0));
      expect(model.humidity, equals(62));
      expect(model.apparentTemperature, equals(30.0));
      expect(model.precipitation, equals(0.4));
      expect(model.weatherCode, equals(61));
      expect(model.windSpeed, equals(11.0));
      expect(WeatherUtils.getWeatherCondition(model.weatherCode), equals('Rainy'));
    });

    test('Weather Advice Engine generates umbrella and clothing recommendations', () {
      final rainyModel = WeatherModel(
        temperature: 29.0,
        humidity: 62,
        apparentTemperature: 30.0,
        precipitation: 0.4,
        weatherCode: 61,
        windSpeed: 11.0,
        windDirection: 180.0,
      );

      final advice = WeatherUtils.getWeatherAdvice(rainyModel);
      final outfit = WeatherUtils.getOutfitRecommendation(rainyModel);
      final activity = WeatherUtils.getOutdoorActivityScore(rainyModel);

      expect(advice.any((a) => a.contains('Rain is present or expected')), isTrue);
      expect(outfit.any((o) => o.contains('Umbrella')), isTrue);
      expect(activity['score'], lessThanOrEqualTo(80));
    });
  });
}
