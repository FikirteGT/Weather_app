# 🌤️ Weather Companion

> An intelligent, beginner-friendly Flutter weather application that answers:  
> **"What does today's weather mean for me?"**

---

## 🌟 Key Features

1. **Live Open-Meteo Integration**: Fetches real-time weather metrics for Addis Ababa (and any global city).
2. **Weather Advice Engine**: Deterministic rules that analyze temperature, precipitation, and wind to generate actionable safety and comfort recommendations.
3. **Today's Outfit Recommendations**: Suggests appropriate clothing and gear (jackets, umbrella, sunglasses) dynamically.
4. **Outdoor Activity Score**: A 0–100 suitability rating with color-coded safety status (*Excellent / Good / Moderate / Poor*).
5. **Weather-Responsive Atmospheric UI**: Dynamic gradient themes that change between sunny, cloudy, and rainy conditions.
6. **Hourly Forecast (Horizontal Scroll)**: Clean hourly prediction cards with smooth scrolling physics.
7. **Global City Search & Bookmarking**: Auto-completing city geocoding with quick-save favorites.
8. **Offline Demo Mode & Error Handling**: Graceful fallback when network connectivity is unavailable.

---

## 📁 Beginner-Friendly Architecture

```text
lib/
  ├── main.dart                      # App entry point & dark theme setup
  ├── screens/
  │   └── home_page.dart             # Main dashboard controller & state
  ├── services/
  │   └── weather_service.dart       # Open-Meteo REST API & geocoding
  ├── models/
  │   └── weather_model.dart         # Strongly-typed data model & fromJson
  ├── utils/
  │   └── weather_utils.dart         # Weather Advice Engine & rules logic
  ├── data/
  │   └── hourly_data.dart           # Hourly prediction demo model & data
  └── widgets/
      ├── weather_header.dart        # Top bar, big temp, condition, & mood
      ├── weather_info_card.dart     # 4-column metric card (Wind, Humidity, Feels Like, Precip)
      ├── weather_advice_card.dart   # Actionable advice checklist
      ├── outfit_card.dart           # Outfit recommendations card
      ├── activity_score_card.dart   # 0–100 Activity score progress bar
      ├── hourly_forecast.dart       # Horizontal hourly forecast list
      ├── search_overlay.dart        # Glassmorphic search dialog
      └── favorites_dialog.dart      # Bookmarked favorite cities manager
```

---

## 🚀 Getting Started

### 1. Prerequisites
* Flutter SDK (3.0.0+)
* Dart SDK (3.0.0+)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/your-username/Weather_app.git

# Navigate to project directory
cd Weather_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🧪 Testing & Code Quality

```bash
# Run all unit and widget tests
flutter test

# Verify linting & clean architecture (0 issues)
flutter analyze
```

---

## 📚 Student Defense & Presentation Documentation

* [🎓 Student Presentation & Defense Guide](STUDENT_DEFENSE_GUIDE.md)
* [🏗️ Architecture & Data Pipeline Guide](docs/01_architecture_and_data_flow.md)
* [📦 Model & Network Service Layer Guide](docs/02_model_and_service_layer.md)
* [🧠 Weather Advice Engine & Rules Guide](docs/03_weather_advice_engine.md)
* [🎨 UI Widgets & Hierarchy Guide](docs/04_ui_widgets_and_screens.md)
