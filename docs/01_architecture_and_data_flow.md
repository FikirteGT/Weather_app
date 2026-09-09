# 🏗️ Architecture & Data Pipeline Guide

## 1. High-Level Concept: "Weather Companion"

"Weather Companion" is not just another standard weather dashboard. Instead of merely showing raw numeric numbers (e.g., 29°C, 62% humidity), it answers the fundamental human question:

> **"What does today's weather mean for me?"**

To answer this, the application separates concerns into **Network Data Ingestion**, **Model Parsing**, **Deterministic Advice Evaluation**, and **Weather-Responsive Presentation**.

---

## 2. End-to-End Data Pipeline

The following diagram illustrates the exact flow of data through the codebase from the Open-Meteo REST API down to the user's screen:

```
+-------------------------------------------------------------+
|                     1. Open-Meteo REST API                  |
|  (Returns raw JSON for Addis Ababa: Lat 8.9806, Lon 38.7578)|
+-------------------------------------------------------------+
                              |
                              v  (HTTP GET Request)
+-------------------------------------------------------------+
|                     2. WeatherService                       |
|           (lib/services/weather_service.dart)               |
|  - Validates HTTP response status 200                       |
|  - Decodes JSON string into Map<String, dynamic>            |
|  - Implements error handling and offline demo fallback      |
+-------------------------------------------------------------+
                              |
                              v  (Factory Constructor)
+-------------------------------------------------------------+
|                      3. WeatherModel                        |
|             (lib/models/weather_model.dart)                 |
|  - Maps raw JSON keys to strongly-typed Dart fields         |
|  - (temperature, humidity, precipitation, windSpeed, etc.)  |
+-------------------------------------------------------------+
                              |
                              v  (State Management)
+-------------------------------------------------------------+
|                   4. HomePage (StatefulWidget)              |
|              (lib/screens/home_page.dart)                   |
|  - Manages Async lifecycle: Loading -> Success -> Error     |
|  - Passes WeatherModel to WeatherUtils & UI Cards           |
+-------------------------------------------------------------+
                              |
                              v  (Deterministic Analysis)
+-------------------------------------------------------------+
|                 5. Weather Advice Engine                    |
|              (lib/utils/weather_utils.dart)                 |
|  - Temperature Rules (Hot / Comfortable / Cool / Cold)      |
|  - Rain & Wind Precaution Rules                             |
|  - Outdoor Activity Score Algorithm (0 to 100)              |
|  - Outfit Recommendation Engine                             |
|  - Weather Mood & Atmospheric Theme Gradients               |
+-------------------------------------------------------------+
                              |
                              v  (Modular Rendering)
+-------------------------------------------------------------+
|                      6. UI Widgets                          |
|  - WeatherHeader         (Condition, Big Temp, Mood)        |
|  - WeatherInfoCard       (Wind, Humidity, Feels Like, Precip)|
|  - WeatherAdviceCard     (Precautions & Umbrella advice)    |
|  - OutfitCard            (Dynamic Clothing Recommendations) |
|  - ActivityScoreCard     (Activity Score 0-100 & Status)    |
|  - HourlyForecastWidget  (Horizontal Hourly Forecast)       |
+-------------------------------------------------------------+
                              |
                              v
                        [ App User ]
```

---

## 3. Why This Architecture is Beginner-Friendly

1. **No External State-Management Clutter**: Avoids Bloc, Riverpod, or Redux overhead. Uses Flutter's native `StatefulWidget` and `setState()`.
2. **Strict Single Responsibility Principle**: Each folder and file does one job:
   * `models/` = Data blueprint.
   * `services/` = Network HTTP communication.
   * `utils/` = Business rules & advice engine.
   * `widgets/` = Individual visual components.
   * `screens/` = Screen assembly & state coordination.
3. **Easy to Explain During Examination**: Every method is short, deterministic, and free of mysterious magic or code-generation.
