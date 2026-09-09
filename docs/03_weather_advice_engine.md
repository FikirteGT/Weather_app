# 🧠 Weather Advice Engine & Business Logic Guide

This guide breaks down `lib/utils/weather_utils.dart` and `lib/data/hourly_data.dart`, detailing the rules-based recommendation engine that powers "Weather Companion".

---

## 1. `lib/utils/weather_utils.dart`

### What it is
A pure Dart utility class containing static deterministic rules that analyze live weather parameters and produce actionable human recommendations.

### Why we created it
To differentiate this app from standard weather apps. Instead of just displaying numerical statistics, `WeatherUtils` provides answers to:
* What should I wear today?
* Do I need an umbrella?
* Is it a good day for outdoor sports or walking?
* What precautions should I take?

### Responsibility
**Single Responsibility**: Business logic, advice generation, scoring calculations, and condition formatting.

---

### Key Rule Engines Breakdown

#### 1. WMO Weather Code Interpretation
Open-Meteo returns World Meteorological Organization (WMO) integer codes:
```dart
static String getWeatherCondition(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 3) return 'Partly cloudy';
  if (code <= 48) return 'Foggy';
  if (code <= 57) return 'Drizzle';
  if (code <= 67) return 'Rainy';
  if (code <= 77) return 'Snowfall';
  if (code <= 82) return 'Rain showers';
  if (code == 95) return 'Thunderstorm';
  if (code >= 96) return 'Thunderstorm with hail';
  return 'Overcast';
}
```

#### 2. Weather Advice Rules
Analyzes temperature, precipitation, and wind speed:
* **Temperature**:
  * $\ge 30^\circ\text{C}$: *"Hot weather — stay hydrated and avoid prolonged heat exposure."*
  * $20^\circ\text{C} - 29^\circ\text{C}$: *"Comfortable temperature — light clothing is recommended."*
  * $15^\circ\text{C} - 19^\circ\text{C}$: *"Cool weather — consider wearing a light jacket."*
  * $< 15^\circ\text{C}$: *"Cold weather — warm clothing and layers are recommended."*
* **Precipitation**:
  * If rain is detected or code is rainy: *"Rain is present or expected — carry an umbrella and wear water-resistant shoes."*
* **Wind**:
  * $> 30\text{ km/h}$: *"Strong winds — be careful during outdoor activities."*
  * $> 15\text{ km/h}$: *"Breezy conditions — enjoy the pleasant air flow."*

#### 3. Outfit Recommendation Engine (`getOutfitRecommendation`)
Dynamically creates a wardrobe checklist combining temperature and precipitation conditions (e.g. Light T-shirt + Breathable pants + Umbrella).

#### 4. Outdoor Activity Score Algorithm (`getOutdoorActivityScore`)
Computes an easy-to-understand score from 0 to 100:
* Starts at **100 points**.
* Deducts **40 points** for heavy rain ($>2\text{ mm}$) or **20 points** for light rain.
* Deducts **25 points** for extreme heat ($>32^\circ\text{C}$) or cold ($<10^\circ\text{C}$).
* Deducts **20 points** for strong wind ($>30\text{ km/h}$).
* Clamps score between **0 and 100** and assigns category:
  * **80–100**: Excellent (Green)
  * **60–79**: Good (Blue)
  * **40–59**: Moderate (Amber)
  * **0–39**: Poor (Red)

#### 5. Weather Mood & Visual Atmosphere
* Generates a personality caption (e.g., *"🌧 Looks like the sky needs an umbrella today."*).
* Returns dynamic `LinearGradient` colors that reflect the atmospheric tone (sunny purple, rainy deep navy, or cloudy slate).

---

## 2. `lib/data/hourly_data.dart`

### What it is
A structured data file defining the `HourlyItem` model and demo placeholder hourly data list.

### Why we created it
The assigned Open-Meteo endpoint provides **current** weather conditions for Addis Ababa. To fulfill the horizontal hourly list UI requirement without falsely claiming fake API integration, this file modularly isolates demo hourly cards so that future multi-hour forecast APIs can plug in seamlessly.

---

## 3. Defense Presentation Questions & Answers

**Q1: Is this recommendation system powered by Artificial Intelligence (AI) or Machine Learning (ML)?**  
> *"No, we explicitly designed it as a deterministic rules-based engine. It applies clear, testable, and explainable meteorological thresholds rather than an opaque black-box AI model."*

**Q2: How does the app change its background theme dynamically?**  
> *"In `HomePage.build()`, we call `WeatherUtils.getWeatherThemeGradients(weather)`. The function evaluates the weather code and precipitation to return custom gradient colors which animate smoothly across the background."*
