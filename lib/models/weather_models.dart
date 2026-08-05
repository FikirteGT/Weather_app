class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int weatherCode;
  final double apparentTemperature;
  final double precipitation;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.apparentTemperature,
    required this.precipitation,
  });

  // Convert API response to our model
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return WeatherData(
      temperature: current['temperature_2m'].toDouble(),
      humidity: current['relative_humidity_2m'].toDouble(),
      windSpeed: current['wind_speed_10m'].toDouble(),
      weatherCode: current['weather_code'].toInt(),
      apparentTemperature: current['apparent_temperature'].toDouble(),
      precipitation: current['precipitation'].toDouble(),
    );
  }

  // Get weather condition text based on weather code
  String get weatherCondition {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      default:
        return 'Unknown';
    }
  }

  // Get weather icon based on weather code
  String get weatherIcon {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌧️';
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 80:
      case 81:
      case 82:
        return '🌧️';
      default:
        return '🌤️';
    }
  }
}
