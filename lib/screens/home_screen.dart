// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../widgets/weather_info_item.dart';
import '../widgets/past_day_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/aqi_recommendation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();
  WeatherData? _weather;
  String? _error;
  bool _isLoading = true;
  bool _isOffline = false;

  // Selected Location State
  String _cityName = 'Addis Ababa';
  String _countryName = 'Ethiopia';
  double _latitude = 8.9806;
  double _longitude = 38.7578;

  // Search UI State
  bool _isSearching = false;
  bool _isSearchingLoading = false;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  // Toggle for daily: Forecast vs History
  bool _showForecast = true;

  // Hourly selection state
  int? _selectedHourlyIndex;

  @override
  void initState() {
    super.initState();
    _loadLocationAndFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to get weather condition string from weather code
  String _getWeatherConditionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snow fall';
    if (code <= 82) return 'Rain showers';
    return 'Thunderstorm';
  }

  // Load last searched location, then pull weather
  Future<void> _loadLocationAndFetch() async {
    try {
      final savedCity = await _service.getSavedCity();
      setState(() {
        _cityName = savedCity['name'];
        _countryName = savedCity['country'] ?? '';
        _latitude = savedCity['latitude'];
        _longitude = savedCity['longitude'];
      });
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
    _fetchWeatherData();
  }

  // Fetch weather data, falling back to cache if offline
  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedHourlyIndex = null; // Reset hourly selection when new location is loaded
    });

    try {
      // Attempt to load from network
      final data = await _service.fetchWeather(latitude: _latitude, longitude: _longitude);
      setState(() {
        _weather = data;
        _isOffline = false;
        _isLoading = false;
      });
    } catch (networkError) {
      debugPrint('Network weather fetch failed: $networkError. Checking cache...');
      
      // Fallback to cache
      final cachedData = await _service.getCachedWeather();
      if (cachedData != null) {
        setState(() {
          _weather = WeatherData.fromJson(cachedData);
          _isOffline = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to fetch weather. Check your internet connection.';
          _isLoading = false;
        });
      }
    }
  }

  // Auto-complete geocoding lookup
  void _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearchingLoading = false;
      });
      return;
    }

    setState(() {
      _isSearchingLoading = true;
    });

    try {
      final results = await _service.fetchLocations(query);
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = results;
          _isSearchingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingLoading = false;
        });
      }
    }
  }

  // Display a popup dialog for secondary features (Notifications/Alerts)
  void _showNotificationAlerts() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B1C33).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Text(
                  'Severe Weather Alerts',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Text(
              _weather != null && _weather!.precipitation > 2.0
                  ? 'Active Alert: Heavy precipitation is currently falling in your area. Avoid outdoor activities if possible.'
                  : 'No active severe weather alerts for $_cityName, $_countryName. Stay safe!',
              style: GoogleFonts.inter(color: Colors.white70, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Dismiss',
                  style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Display a popup dialog for the Map option
  void _showRadarMapComingSoon() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B1C33).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              children: [
                const Icon(Icons.map_outlined, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Text(
                  'Interactive Radar Map',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const RadialGradient(
                      colors: [Color(0x3338BDF8), Color(0x0038BDF8)],
                      radius: 0.8,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Center(
                    child: Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Precipitation radar overlays and interactive regional maps are simulated for $_cityName. Check back in the next release!',
                  style: GoogleFonts.inter(color: Colors.white70, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it',
                  style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Dynamic Theme Gradients and Accent Colors based on weather and time of day
  WeatherTheme _getWeatherTheme() {
    if (_weather == null) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF19182C), const Color(0xFF0F0E1E), const Color(0xFF0A0914)],
        glowColor: const Color(0xFFE58843).withOpacity(0.22),
        accentColor: const Color(0xFF38BDF8),
      );
    }

    final bool isNight = _weather!.isNight;
    final int code = _weather!.weatherCode;

    if (isNight) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF0B0A16), const Color(0xFF06050C), const Color(0xFF020105)],
        glowColor: const Color(0xFF8B5CF6).withOpacity(0.2), // Purple/Indigo glow
        accentColor: const Color(0xFF8B5CF6),
      );
    }

    // Rainy conditions (61-67, 80-82, 95+)
    if (code == 61 || code == 63 || code == 65 || code == 80 || code == 81 || code == 82 || code >= 95) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF151B29), const Color(0xFF0C1019), const Color(0xFF06080D)],
        glowColor: const Color(0xFF38BDF8).withOpacity(0.2), // Cool blue rain glow
        accentColor: const Color(0xFF38BDF8),
      );
    }

    // Cloudy/Foggy conditions (1-3, 45, 48)
    if (code <= 3 || code == 45 || code == 48) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF18202B), const Color(0xFF0D1219), const Color(0xFF06090D)],
        glowColor: const Color(0xFF64748B).withOpacity(0.22), // Soft slate glow
        accentColor: const Color(0xFF64748B),
      );
    }

    // Sunny/Clear (0)
    return WeatherTheme(
      bgGradients: [const Color(0xFF1B1936), const Color(0xFF0F0E20), const Color(0xFF090814)],
      glowColor: const Color(0xFFE58843).withOpacity(0.26), // Golden glowing orange
      accentColor: const Color(0xFFE58843),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getWeatherTheme();

    return Scaffold(
      backgroundColor: theme.bgGradients.last,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.bgGradients,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Radial glow behind weather illustration
              if (!_isSearching && !_isLoading && _error == null)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.glowColor,
                            theme.glowColor.withOpacity(0.0),
                          ],
                          radius: 0.75,
                        ),
                      ),
                    ),
                  ),
                ),

              // Main loading or error check
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _error!,
                                  style: GoogleFonts.inter(color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _fetchWeatherData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : Positioned.fill(
                          child: _buildContent(_weather!, theme),
                        ),

              // Search Overlay View (Blurred glassmorphism overlay)
              if (_isSearching) _buildSearchOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherData weather, WeatherTheme theme) {
    return Stack(
      children: [
        // Scrollable content area
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                          // Custom Top Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isSearching = true),
                                child: _buildMenuIcon(theme.accentColor),
                              ),
                              _buildLocationHeader(),
                              GestureDetector(
                                onTap: _showNotificationAlerts,
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Main Weather Illustration & Selected Hour Indicator
                          Column(
                            children: [
                              if (_selectedHourlyIndex != null) ...[
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.accentColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.accentColor.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_filled_rounded,
                                          color: theme.accentColor,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Hourly View: ${DateFormat('HH:mm').format(weather.hourlyForecast[_selectedHourlyIndex!].time)}',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => setState(() => _selectedHourlyIndex = null),
                                          child: Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.white.withOpacity(0.6),
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Center(
                                child: Image.asset(
                                  _selectedHourlyIndex != null
                                      ? weather.hourlyForecast[_selectedHourlyIndex!].weatherImage
                                      : weather.weatherImage,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Temperature Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(_selectedHourlyIndex != null ? weather.hourlyForecast[_selectedHourlyIndex!].temperature : weather.temperature).round()}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 68,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 2),
                                child: Text(
                                  '°',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w300,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 4),
                                child: Text(
                                  'c',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Weather Expectation/Condition
                          Center(
                            child: Text(
                              _selectedHourlyIndex != null
                                  ? _getWeatherConditionFromCode(weather.hourlyForecast[_selectedHourlyIndex!].weatherCode)
                                  : weather.weatherCondition,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Stats Row (Wind, Humidity, Daylight hours)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              WeatherInfoItem(
                                icon: Icons.air_rounded,
                                value: '${weather.windSpeed.round()}km/h',
                              ),
                              WeatherInfoItem(
                                icon: Icons.opacity_rounded,
                                value: '${weather.humidity.round().toString().padLeft(2, '0')}%',
                              ),
                              WeatherInfoItem(
                                icon: Icons.wb_sunny_outlined,
                                value: '${weather.daylightHours.toStringAsFixed(1).replaceAll('.0', '')}hr',
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // NEW: Hourly Forecast Section
                          _buildSectionHeader('Hourly Forecast', theme.accentColor),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: weather.hourlyForecast.length,
                              itemBuilder: (context, index) {
                                final hour = weather.hourlyForecast[index];
                                return HourlyForecastCard(
                                  time: hour.time,
                                  temperature: hour.temperature,
                                  imagePath: hour.weatherImage,
                                  isCurrent: index == 0,
                                  isSelected: _selectedHourlyIndex == index,
                                  onTap: () => setState(() => _selectedHourlyIndex = index),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),

                          // NEW: AQI and Smart Activity Recommendations
                          AqiRecommendationCard(
                            aqi: weather.usAqi,
                            aqiStatus: weather.aqiStatus,
                            aqiColor: weather.aqiColor,
                            pm25: weather.pm25,
                            pm10: weather.pm10,
                            recommendation: weather.activitySuggestion,
                          ),
                          const SizedBox(height: 28),

                          // Forecast vs History Toggle Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _showForecast ? '7-Day Forecast' : 'Past Days Weather',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              // Glass Switch Widget
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _showForecast = true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _showForecast ? theme.accentColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Forecast',
                                          style: GoogleFonts.inter(
                                            color: _showForecast ? Colors.black : Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _showForecast = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: !_showForecast ? theme.accentColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'History',
                                          style: GoogleFonts.inter(
                                            color: !_showForecast ? Colors.black : Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Daily List Display (Forecast vs History)
                          _buildDailyList(weather),
                        ],
                      ),
                    ),
                  ),
                ),

        // Floating Bottom Nav Bar
        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E203B).withOpacity(0.65),
              borderRadius: BorderRadius.circular(31),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isSearching) {
                      setState(() {
                        _isSearching = false;
                      });
                    }
                  },
                  child: _buildNavButton(Icons.home_rounded, !_isSearching),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  child: _buildNavButton(Icons.search_rounded, _isSearching),
                ),
                GestureDetector(
                  onTap: _showNotificationAlerts,
                  child: _buildNavButton(Icons.notifications_none_rounded, false),
                ),
                GestureDetector(
                  onTap: _showRadarMapComingSoon,
                  child: _buildNavButton(Icons.map_outlined, false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyList(WeatherData weather) {
    // Determine which list to display
    final listItems = _showForecast ? weather.dailyForecast : weather.pastDays;

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40; // subtract padding (20 left + 20 right)
    final totalMargins = (listItems.length - 1) * 8; // margins
    final minRequiredWidth = (listItems.length * 90) + totalMargins;

    if (availableWidth > minRequiredWidth) {
      // Stretch evenly on wide screens
      return SizedBox(
        height: 124,
        child: Row(
          children: listItems.map((p) {
            final dayLabel = p is DailyForecast ? p.dateLabel : (p as PastDayWeather).dateLabel;
            final temp = p is DailyForecast 
                ? '${p.maxTemp.round()}°' 
                : '${(p as PastDayWeather).maxTemp.round()}°';
            final img = p is DailyForecast ? p.weatherImage : (p as PastDayWeather).weatherImage;

            return Expanded(
              child: PastDayWeatherCardWrapper(
                dayLabel: dayLabel,
                temperature: temp,
                imagePath: img,
                width: null,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Scrollable horizontal list on mobile
      return SizedBox(
        height: 124,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            final p = listItems[index];
            final dayLabel = p is DailyForecast ? p.dateLabel : (p as PastDayWeather).dateLabel;
            final temp = p is DailyForecast 
                ? '${p.maxTemp.round()}°' 
                : '${(p as PastDayWeather).maxTemp.round()}°';
            final img = p is DailyForecast ? p.weatherImage : (p as PastDayWeather).weatherImage;

            return PastDayWeatherCardWrapper(
              dayLabel: dayLabel,
              temperature: temp,
              imagePath: img,
              width: 90,
            );
          },
        ),
      );
    }
  }

  // Visual helper for hamburger menu icon (toggles search)
  Widget _buildMenuIcon(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 14,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: _cityName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_countryName.isNotEmpty)
                TextSpan(
                  text: ', $_countryName',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
            ],
          ),
        ),
        if (_isOffline) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Offline mode. Showing cached weather.',
            child: Icon(
              Icons.cloud_off_rounded,
              color: Colors.amberAccent.withOpacity(0.8),
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        size: 24,
      ),
    );
  }

  // Premium full-screen autocomplete location search overlay
  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: const Color(0xFF0A0914).withOpacity(0.75),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search city...',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                              ),
                              autofocus: true,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchResults = [];
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Results List
              Expanded(
                child: _isSearchingLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white30),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.length < 2
                                  ? 'Type a city name to search'
                                  : 'No matching cities found',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.white.withOpacity(0.05),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final city = _searchResults[index];
                              final String title = city['name'];
                              final String subtitle = [
                                if (city['admin1'].toString().isNotEmpty) city['admin1'],
                                if (city['country'].toString().isNotEmpty) city['country'],
                              ].join(', ');

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                title: Text(
                                  title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  subtitle,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF38BDF8),
                                  size: 20,
                                ),
                                onTap: () async {
                                  final selectedCityName = city['name'];
                                  final selectedCountry = city['country'];
                                  final selectedLat = city['latitude'];
                                  final selectedLon = city['longitude'];

                                  setState(() {
                                    _isSearching = false;
                                    _cityName = selectedCityName;
                                    _countryName = selectedCountry;
                                    _latitude = selectedLat;
                                    _longitude = selectedLon;
                                    _isLoading = true;
                                  });

                                  _searchController.clear();
                                  _searchResults = [];

                                  // Cache selected city coordinates
                                  await _service.saveSelectedCity(
                                    selectedCityName,
                                    selectedCountry,
                                    selectedLat,
                                    selectedLon,
                                  );

                                  // Fetch new weather
                                  _fetchWeatherData();
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small helper model to capture theme colors
class WeatherTheme {
  final List<Color> bgGradients;
  final Color glowColor;
  final Color accentColor;

  WeatherTheme({
    required this.bgGradients,
    required this.glowColor,
    required this.accentColor,
  });
}

// A wrapper widget that forwards data to the existing PastDayCard class.
// This is necessary because some daily forecasts might represent tomorrow/future days,
// but they share the exact layout of PastDayCard.
class PastDayWeatherCardWrapper extends StatelessWidget {
  final String dayLabel;
  final String temperature;
  final String imagePath;
  final double? width;

  const PastDayWeatherCardWrapper({
    super.key,
    required this.dayLabel,
    required this.temperature,
    required this.imagePath,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return PastDayCard(
      dayLabel: dayLabel,
      temperature: temperature,
      imagePath: imagePath,
      width: width,
    );
  }
}
