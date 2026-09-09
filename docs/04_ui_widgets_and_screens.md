# 🎨 UI Widgets & Screens Guide

This guide breaks down every UI component in the **Weather Companion** app, detailing widget hierarchy, Flutter layout concepts, and responsiveness.

---

## 1. Entry Point & Screen Controller

### `lib/main.dart`
* **What it is**: The root entry point of the Flutter application.
* **Important lines**:
  ```dart
  void main() => runApp(const WeatherCompanionApp());
  ```
  Sets up `MaterialApp` with a dark theme (`Color(0xFF0A0914)`) and launches `HomePage`.

### `lib/screens/home_page.dart`
* **What it is**: The primary dashboard controller (`StatefulWidget`).
* **Responsibilities**:
  1. Manages state variables: `_weatherData`, `_isLoading`, `_errorMessage`, `_currentCity`, `_favoriteCities`.
  2. Implements `_loadWeather()` with `try-catch` error handling and pull-to-refresh (`RefreshIndicator`).
  3. Provides seamless navigation between **Home**, **Search Overlay**, and **Favorites List**.
  4. Renders responsive loading, error, and weather content states.

---

## 2. Modular Widget Breakdown

### `lib/widgets/weather_header.dart`
* **Displays**: City name, heart favorite button, search menu trigger, calendar icon, weather illustration, large temperature readout (°C), condition subtitle, and personality Mood banner.
* **Layout**: `Column` nesting `Row` for navigation, followed by a glowing circular weather icon and large typography (`72px` temperature).

### `lib/widgets/weather_info_card.dart`
* **Displays**: Current live metrics in a horizontal 4-column layout:
  * **Wind Speed** (`km/h`)
  * **Humidity** (`%`)
  * **Feels Like** (`°C`)
  * **Precipitation** (`mm`)
* **Layout**: `Container` with rounded corners (`24px`), glass styling, and vertical divider separators.

### `lib/widgets/weather_advice_card.dart`
* **Displays**: Bulleted actionable recommendations from the **Weather Advice Engine** (hydration tips, jacket alerts, umbrella warnings).
* **Layout**: Glowing header with a lightbulb icon + dynamic `.map()` checklist.

### `lib/widgets/outfit_card.dart`
* **Displays**: Wardrobe recommendations tailored to live temperature and rain status.
* **Layout**: Purple accent styling with `Icons.checkroom_rounded` and garment bullet points.

### `lib/widgets/activity_score_card.dart`
* **Displays**: Outdoor activity suitability score (0–100), status badge (*Excellent / Good / Moderate / Poor*), and an animated `LinearProgressIndicator` color-coded to the condition.

### `lib/widgets/hourly_forecast.dart`
* **Displays**: Horizontally scrollable `ListView.builder` showing 6 hourly forecast cards (*NOW, 5 PM, 6 PM, 7 PM, 8 PM, 9 PM*) with time, weather icon, and temperature.

### `lib/widgets/search_overlay.dart`
* **Displays**: Glassmorphic search dialog (`BackdropFilter`) allowing users to type and search any global city with auto-complete geocoding.

### `lib/widgets/favorites_dialog.dart`
* **Displays**: Bookmarked favorite cities list with one-tap switching and quick deletion.

---

## 3. Defense Presentation Questions & Answers

**Q1: How did you ensure the layout doesn't overflow on smaller mobile screens?**  
> *"We wrapped the dashboard in a `SingleChildScrollView` with `BouncingScrollPhysics()` and used flexible components like `Expanded` and `ListView.builder` for the hourly forecast rather than hardcoding static screen heights."*

**Q2: How does the Pull-to-Refresh feature work?**  
> *"We wrapped the scrollable content in a `RefreshIndicator` whose `onRefresh` callback triggers `_loadWeather()`. When the user swipes down, live data is re-fetched from Open-Meteo."*
