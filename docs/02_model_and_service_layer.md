# 📦 Model & Network Service Layer Guide

This guide breaks down `lib/models/weather_model.dart` and `lib/services/weather_service.dart` with beginner-friendly explanations, line-by-line code breakdowns, and presentation defense Q&A.

---

## 1. `lib/models/weather_model.dart`

### What it is
A plain Dart class that defines the structure and types of the weather data used throughout our application.

### Why we created it
When the Open-Meteo API responds, it returns a raw JSON text string. If we tried to access values using string keys everywhere like `json["current"]["temperature_2m"]`, typos would crash the app at runtime. `WeatherModel` converts loosely-typed JSON maps into strongly-typed Dart objects with compile-time type safety.

### Responsibility
**Single Responsibility**: Data Modeling and JSON-to-Dart conversion.

### Important Code Breakdown

```dart
class WeatherModel {
  final double temperature;         // temperature in °C (e.g., 29.0)
  final int humidity;               // relative humidity in % (e.g., 62)
  final double apparentTemperature; // feels-like temp in °C (e.g., 30.0)
  final double precipitation;       // rain/snow in mm (e.g., 0.4)
  final int weatherCode;            // WMO code (e.g., 61 for light rain)
  final double windSpeed;           // wind speed in km/h (e.g., 11.0)
  final double windDirection;       // wind direction in degrees (e.g., 180.0)
```
* **`final` fields**: Ensures that once a weather snapshot is created, it cannot be mutated accidentally.

```dart
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
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
```
* **`factory` constructor**: Returns an instance of `WeatherModel` created from parsed JSON map data.
* **`as num?` and `?.toDouble()`**: Defensive parsing. In JSON, numbers can arrive as integers (`29`) or doubles (`29.0`). Casting to `num` first safely handles both without runtime type errors.
* **`?? 0.0` (Null-safety fallback)**: If any field is missing from the API response, safe default values prevent `NullCheckError` app crashes.

---

## 2. `lib/services/weather_service.dart`

### What it is
A dedicated networking class responsible for communicating with the external Open-Meteo REST API over HTTP.

### Why we created it
The UI (`HomePage` and widgets) should **never** make direct HTTP network calls. Separating network operations into a service class keeps the UI clean and makes testing and offline mocking simple.

### Responsibility
**Single Responsibility**: HTTP Network requests, URL parameter construction, JSON decoding, and geocoding search.

### Important Code Breakdown

```dart
class WeatherService {
  Future<WeatherModel> fetchCurrentWeather({
    double latitude = 8.9806,      // Defaults to Addis Ababa coordinates
    double longitude = 38.7578,
  }) async {
    final Uri uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
    });
```
* **`Uri.https()`**: Safely constructs the URL with proper encoding for all query parameters.
* **`Future<WeatherModel>`**: Indicates that this method will complete asynchronously in the future.
* **`async` and `await`**:
  * `async` allows the function to execute asynchronous code without freezing the Flutter UI thread.
  * `await http.get(uri)` pauses execution inside this function until the network response arrives from the server.

```dart
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Server responded with status code: ${response.statusCode}');
    }
```
* **`response.statusCode == 200`**: Verifies that the HTTP request succeeded before decoding the body.
* **`jsonDecode(response.body)`**: Converts the raw JSON text string into a structured Dart Map.

---

## 3. Defense Presentation Questions & Answers (Exam Prep)

**Q1: Why did you use a factory constructor in `WeatherModel`?**  
> *"A factory constructor in Dart doesn't always create a new instance using default constructors; it allows us to run custom logic, validate data, and parse incoming Map key-value pairs before constructing the strongly-typed object."*

**Q2: What happens if there is no internet connection during `fetchCurrentWeather`?**  
> *"The `http.get` call throws an exception which is caught by the `try-catch` block in `HomePage`. `HomePage` sets `_errorMessage` and renders an intuitive error screen with a 'Try Again' button and an 'Offline Demo' button."*
